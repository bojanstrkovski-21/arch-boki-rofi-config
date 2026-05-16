#!/usr/bin/env bash
# =============================================================================
# show-keys-python.sh — launch the Dear PyGui keybindings viewer
# =============================================================================

BOKI_USER="$(whoami)"
BOKI_HOME="/home/${BOKI_USER}"
BOKI_CONFIG="${BOKI_HOME}/.config/arch-boki-main-menu"

SCRIPT="${BOKI_CONFIG}/scripts/show_keybindings.py"
TERMINAL="${TERMINAL:-alacritty}"

# Ensure dearpygui is available
if ! python3 -c "import dearpygui" 2>/dev/null; then
    setsid "$TERMINAL" \
        --class BokiPresent \
        -e bash -c "
            echo
            printf '  \e[1m%s\e[0m\n\n' 'arch-boki — installing python-dearpygui'
            sudo pacman -S --noconfirm python-dearpygui
            echo
            if python3 -c 'import dearpygui' 2>/dev/null; then
                printf '  \e[32mInstallation complete.\e[0m\n'
            else
                printf '  \e[31mInstallation failed. Run: sudo pacman -S python-dearpygui\e[0m\n'
            fi
            echo
            printf '  Press any key to close...'
            read -n1 -s
        "
    # Re-check after terminal closes
    if ! python3 -c "import dearpygui" 2>/dev/null; then
        notify-send -u critical "arch-boki" "dearpygui not available. Run: sudo pacman -S python-dearpygui"
        exit 1
    fi
fi

setsid python3 "$SCRIPT" >/dev/null 2>&1 &
disown
