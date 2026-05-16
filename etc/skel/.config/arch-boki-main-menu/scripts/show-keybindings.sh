#!/usr/bin/env bash
# =============================================================================
# show-keybindings.sh — display chadwm keybindings in a rofi menu
# Reads from sxhkdrc and config.def.h
# =============================================================================

BOKI_USER="$(whoami)"
BOKI_HOME="/home/${BOKI_USER}"
BOKI_CONFIG="${BOKI_HOME}/.config/arch-boki-main-menu"

SXHKDRC="${BOKI_HOME}/.config/chadwm-boki/sxhkd/sxhkdrc"
CONFIG_H="${BOKI_HOME}/.config/chadwm-boki/chadwm-boki/config.def.h"

BINDINGS=""

# Parse sxhkdrc if it exists
if [[ -f "$SXHKDRC" ]]; then
    BINDINGS+="=== SXHKD KEYBINDINGS ===\n"
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue
        # Key line (no leading whitespace)
        if [[ ! "$line" =~ ^[[:space:]] ]]; then
            KEY="$line"
        else
            CMD=$(echo "$line" | xargs)
            BINDINGS+="${KEY}  →  ${CMD}\n"
        fi
    done < "$SXHKDRC"
    BINDINGS+="\n"
fi

# Parse config.def.h for Key bindings if it exists
if [[ -f "$CONFIG_H" ]]; then
    BINDINGS+="=== CHADWM KEYBINDINGS (config.def.h) ===\n"
    while IFS= read -r line; do
        if [[ "$line" =~ \{[[:space:]]*(MODKEY[^,]*)[[:space:]]*,[[:space:]]*XK_([a-zA-Z0-9_]+) ]]; then
            MOD="${BASH_REMATCH[1]}"
            KEY="${BASH_REMATCH[2]}"
            BINDINGS+="${MOD} + ${KEY}\n"
        fi
    done < "$CONFIG_H"
fi

if [[ -z "$BINDINGS" ]]; then
    notify-send "arch-boki" "No keybinding files found at:\n${SXHKDRC}\n${CONFIG_H}"
    exit 1
fi

echo -e "$BINDINGS" | rofi -dmenu \
    -p "Keybindings" \
    -no-show-match \
    -no-fixed-num-lines \
    -width 60 \
    2>/dev/null
