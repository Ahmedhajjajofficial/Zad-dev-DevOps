#!/bin/bash
while true; do
    if ! pgrep -x "zed" > /dev/null; then
        /home/kasm-user/.local/bin/zed &
    fi
    if ! pgrep -f "code-server" > /dev/null; then
        code-server --bind-addr 0.0.0.0:8080 &
    fi
    sleep 60
done
