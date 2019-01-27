#!/usr/bin/env sh

# Start rtorrent in tmux
tmux new -d -s rtorrent /usr/local/bin/rtorrent

# Wait for rtorrent to finish before exiting
wait
