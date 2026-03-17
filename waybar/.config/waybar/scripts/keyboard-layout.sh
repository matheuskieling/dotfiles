#!/bin/bash

layout=$(hyprctl devices | grep "active keymap" | sed 's/.*: //')

if [[ "$layout" == *"intl"* ]]; then
    echo "INTL"
else
    echo "US"
fi
