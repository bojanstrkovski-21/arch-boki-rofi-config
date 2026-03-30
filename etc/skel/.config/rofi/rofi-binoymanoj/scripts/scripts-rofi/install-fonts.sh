#!/bin/bash
# install-fonts.sh — Rofi-based font installer

ROFI_THEME="$HOME/.config/rofi/everforest-center.rasi"
FONT_VERSION="v3.4.0"
FONTS_DIR="$HOME/.local/share/fonts"

regular_fonts=(
    "ttf-croscore"
    "ttf-carlito"
    "ttf-caladea"
    "opendesktop-fonts"
    "inter-font"
    "ttf-opensans"
    "terminus-font"
    "freetype2"
    "ttf-ms-fonts"
    "ttf-mac-fonts"
    "ttf-macedonian-ancient"
    "ttf-macedonian-church"
    "ttf-material-design-iconic-font"
    "otf-font-awesome"
    "ttf-font-awesome-6"
    "noto-fonts"
    "noto-fonts-cjk"
    "noto-fonts-emoji"
    "noto-fonts-extra"
    "ttf-anonymous-pro"
    "ttf-cascadia-code"
    "ttf-dejavu"
    "ttf-fantasque-sans-mono"
    "ttf-fira-mono"
    "ttf-fira-sans"
    "ttf-fira-code"
    "ttf-hack"
    "ttf-hellvetica"
    "ttf-jetbrains-mono"
    "ttf-joypixels"
    "ttf-roboto"
    "ttf-roboto-mono"
    "ttf-ubuntu-font-family"
)

nerd_fonts=(
    "CascadiaCode"
    "CascadiaMono"
    "DejaVuSansMono"
    "DroidSansMono"
    "FantasqueSansMono"
    "FiraCode"
    "FiraMono"
    "GeistMono"
    "Hack"
    "Iosevka"
    "JetBrainsMono"
    "Lilex"
    "Meslo"
    "Mononoki"
    "NerFontsSymbolsOnly"
    "Noto"
    "Overpass"
    "RobotoMono"
    "SourceCodePro"
    "SpaceMono"
    "Ubuntu"
    "UbuntuMono"
    "UbuntuSans"
    "VictorMono"
)

install_regular_fonts() {
    local selected
    selected=$(printf 'ALL\n%s\n' "${regular_fonts[@]}" \
        | rofi -dmenu -multi-select -p "Regular Fonts (Shift+Enter = multi-select, Enter = confirm)" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$selected" ]] && return

    local to_install=()
    if echo "$selected" | grep -q "^ALL$"; then
        to_install=("${regular_fonts[@]}")
    else
        while IFS= read -r font; do
            [[ -n "$font" ]] && to_install+=("$font")
        done <<< "$selected"
    fi

    [[ ${#to_install[@]} -eq 0 ]] && return

    echo "Installing ${#to_install[@]} regular font package(s)..."
    sudo pacman -S --needed --noconfirm "${to_install[@]}"
    sudo fc-cache -f -v
    echo "Regular fonts installation complete."
}

install_nerd_fonts() {
    local selected
    selected=$(printf 'ALL\n%s\n' "${nerd_fonts[@]}" \
        | rofi -dmenu -multi-select -p "Nerd Fonts (Shift+Enter = multi-select, Enter = confirm)" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$selected" ]] && return

    local to_install=()
    if echo "$selected" | grep -q "^ALL$"; then
        to_install=("${nerd_fonts[@]}")
    else
        while IFS= read -r font; do
            [[ -n "$font" ]] && to_install+=("$font")
        done <<< "$selected"
    fi

    [[ ${#to_install[@]} -eq 0 ]] && return

    mkdir -p "$FONTS_DIR"
    local temp_dir="/tmp/nerdfonts_install_$$"
    mkdir -p "$temp_dir"

    local installed=0 skipped=0 failed=0

    for font in "${to_install[@]}"; do
        echo "Processing: $font"
        if [ -d "$FONTS_DIR/$font" ] && [ "$(ls -A "$FONTS_DIR/$font" 2>/dev/null)" ]; then
            echo "  $font already installed, skipping."
            ((skipped++))
            continue
        fi
        if wget --timeout=30 -q --show-progress \
            "https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/${font}.zip" \
            -P "$temp_dir"; then
            mkdir -p "$FONTS_DIR/$font"
            if unzip -q "$temp_dir/${font}.zip" -d "$FONTS_DIR/$font/" 2>/dev/null; then
                echo "  Installed $font"
                ((installed++))
            else
                echo "  Failed to extract $font"
                rm -rf "$FONTS_DIR/$font"
                ((failed++))
            fi
            rm -f "$temp_dir/${font}.zip"
        else
            echo "  Failed to download $font"
            ((failed++))
        fi
    done

    fc-cache -f
    rm -rf "$temp_dir"

    echo ""
    echo "Nerd Fonts summary:"
    echo "  Installed: $installed  |  Skipped: $skipped  |  Failed: $failed"
}

show_fonts_menu() {
    echo "󰛖 Regular Fonts"
    echo "󰛖 Nerd Fonts"
    echo "󰛖 Both"
    echo "󰐥 Quit"
}

CHOICE=$(show_fonts_menu | rofi -dmenu -i -p "Arch-Boki | Font Installer" -theme "$ROFI_THEME")
[[ $? -ne 0 || -z "$CHOICE" ]] && exit 0

case "$CHOICE" in
    *"Regular Fonts") install_regular_fonts ;;
    *"Nerd Fonts")    install_nerd_fonts ;;
    *"Both")          install_regular_fonts; install_nerd_fonts ;;
    *"Quit")          exit 0 ;;
esac
