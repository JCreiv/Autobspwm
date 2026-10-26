#!/bin/bash

TARGET=$(tr -d '\n\r ' < /tmp/.target 2>/dev/null)

if [ -n "$TARGET" ]; then
    printf '%s' "$TARGET" | xclip -selection clipboard
fi