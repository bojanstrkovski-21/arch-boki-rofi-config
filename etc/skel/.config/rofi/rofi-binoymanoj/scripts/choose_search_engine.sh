#!/bin/bash

# Detect default browser
browser=$(xdg-settings get default-web-browser)
case $browser in
google-chrome* | brave-basic | brave-browser* | microsoft-edge* | opera* | vivaldi*) ;;
*) browser="chromium.desktop" ;;
esac

# Get browser executable from .desktop file
browser_exec=$(sed -n 's/^Exec=\([^ ]*\).*/\1/p' {~/.local,~/.nix-profile,/usr}/share/applications/$browser 2>/dev/null | head -1)

# Search engine options
declare -A engines=(
    ["Google"]="https://www.google.com"
    ["DuckDuckGo"]="https://www.duckduckgo.com"
    ["Wikipedia"]="https://www.wikipedia.org"
)

# Create menu options
options=$(printf '%s\n' "${!engines[@]}" | sort)

# Show rofi menu
selected=$(echo "$options" | rofi -dmenu -p "Choose search engine")

# Check if selection was made
if [ -z "$selected" ]; then
    exit 1
fi

# Open selected search engine
url="${engines[$selected]}"
exec setsid "$browser_exec" --app="$url"

exit 0