#!/usr/bin/env sh

# Start rtorrent in a screen
screen -D -m -S rtorrent /usr/local/bin/rtorrent &

# Wait for rtorrent to finish before exiting
wait
