#!/bin/bash
export DISPLAY=:1
# Note: In ARM64 environment, the library path might differ, but we follow the plan
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
/home/kasm-user/.local/bin/zed --foreground --wait
