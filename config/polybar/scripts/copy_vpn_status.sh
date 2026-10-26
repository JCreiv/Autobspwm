#!/bin/bash

STATUS=$(~/.config/polybar/scripts/ethernet_status.sh)

printf '%s' "$STATUS" | xclip -selection clipboard
