FROM alpine:3.8

RUN apk add --no-cache \
		nginx \
		ca-certificates \
		fcgi \
		ffmpeg \
		geoip \
		gzip \
		nginx \
		php7 \
		php7-cgi \
		php7-fpm \
		php7-json  \
		php7-mbstring \
		php7-pear \
		tar \
		unrar \
		unzip \
		wget \
		zip \
		git \
		curl \
		openssl \
		mediainfo

# s6 overlay
RUN apk add --no-cache curl \
	&& curl -L -s https://github.com/just-containers/s6-overlay/releases/download/v1.21.7.0/s6-overlay-amd64.tar.gz \
		| tar xvzf - -C /

RUN git clone https://github.com/Novik/ruTorrent.git /var/www/html
RUN chown -R nginx:nginx /var/www/html && \
	mkdir -p /run/nginx && \
	rm /etc/nginx/conf.d/default.conf && \
	sed -i 's/nobody/nginx/g' /etc/php7/php-fpm.d/www.conf

COPY root/ /
ENTRYPOINT ["/init"]
