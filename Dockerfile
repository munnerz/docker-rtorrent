FROM alpine:3.6 AS build

RUN apk add --no-cache \
	  curl \
	  git \
	  make \
	  automake \
	  autoconf \
	  libtool \
	  openssl \
	  ca-certificates \
	  g++ \
	  ncurses-dev \
	  curl-dev \
	  zlib-dev \
	  openssl-dev \
	  linux-headers

ENV LIBTORRENT_REVISION v0.13.7
ENV RTORRENT_REVISION v0.9.7
ENV XMLRPC_VERSION 1.43.08

ENV OUTPUT_DIR /out
ENV PATH $PATH:$OUTPUT_DIR/bin
ENV PKG_CONFIG_PATH $OUTPUT_DIR/lib/pkgconfig

WORKDIR /tmp

RUN mkdir -p $OUTPUT_DIR
RUN curl -o xmlrpc-c-$XMLRPC_VERSION.tgz "https://kent.dl.sourceforge.net/project/xmlrpc-c/Xmlrpc-c%20Super%20Stable/$XMLRPC_VERSION/xmlrpc-c-$XMLRPC_VERSION.tgz" \
	&& tar -C $OUTPUT_DIR/ -xvf xmlrpc-c-$XMLRPC_VERSION.tgz \
	&& cd $OUTPUT_DIR/xmlrpc-c-$XMLRPC_VERSION \
	&& ./configure --prefix=$OUTPUT_DIR \
	&& make \
	&& make install

RUN git clone https://github.com/rakshasa/libtorrent \
	&& cd libtorrent \
	&& git reset --hard $LIBTORRENT_REVISION \
	&& ./autogen.sh \
	&& ./configure --prefix=$OUTPUT_DIR --enable-static --disable-shared \
	&& make -j2 \
	&& make install

ENV libtorrent_CFLAGS "-I$OUTPUT_DIR/include"
ENV libtorrent_LIBS "-L$OUTPUT_DIR/lib"
ENV LDFLAGS "-L$OUTPUT_DIR/lib"
ENV CPPFLAGS "-I$OUTPUT_DIR/include"

RUN git clone https://github.com/rakshasa/rtorrent \
	&& cd rtorrent \
	&& git reset --hard $RTORRENT_REVISION \
	&& ./autogen.sh \
	&& ./configure --prefix=$OUTPUT_DIR --enable-static --disable-shared --with-xmlrpc-c \
	&& make -j2

FROM alpine:3.6

RUN apk add --no-cache \
		ncurses \
		libcurl \
		zlib \
		libstdc++ \
		libgcc \
		openssl-dev

COPY --from=build /out /out
COPY --from=build /tmp/rtorrent/src/rtorrent /usr/local/bin/rtorrent

ENV LD_LIBRARY_PATH /out/lib

RUN adduser -D -u 1000 rtorrent

USER rtorrent
COPY .rtorrent.rc /home/rtorrent/.rtorrent.rc
RUN mkdir -p /home/rtorrent/rtorrent/config.d
RUN chown -R rtorrent:rtorrent /home/rtorrent

ENTRYPOINT ["/usr/local/bin/rtorrent"]
