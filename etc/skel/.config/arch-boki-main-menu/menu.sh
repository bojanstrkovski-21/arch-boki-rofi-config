#!/usr/bin/env bash
# =============================================================================
# arch-boki-main-menu — hierarchical system menu for chadwm / X11
# Inspired by ohmychadwm-menu (erikdubois) and omarchy-menu (basecamp/omarchy)
#
# Dependencies:
#   rofi          — menu renderer        (pacman -S rofi)
#   notify-send   — notifications        (pacman -S libnotify)
#   xclip         — clipboard            (pacman -S xclip)
#   maim + slop   — screenshots          (pacman -S maim slop)
#   feh           — wallpaper setter     (pacman -S feh)
#   thunar        — file manager         (pacman -S thunar)
#   neovim        — editor               (pacman -S neovim)
#   fzf           — fuzzy finder         (pacman -S fzf)
#   xdg-open      — open URLs / files
#   xcolor        — colour picker        (pacman -S xcolor)     [optional]
#   redshift      — night light          (pacman -S redshift)   [optional]
#   xautolock     — idle lock            (pacman -S xautolock)  [optional]
#   duf           — disk usage           (pacman -S duf)        [optional]
#   btop          — system monitor       (pacman -S btop)       [optional]
#   nvtop         — GPU monitor          (pacman -S nvtop)      [optional]
#   fastfetch     — system info          (pacman -S fastfetch)  [optional]
#   inxi          — system info          (pacman -S inxi)       [optional]
#
# Install path: ~/.config/arch-boki-main-menu/menu.sh
# Make executable: chmod +x ~/.config/arch-boki-main-menu/menu.sh
# Symlink to PATH: ln -s ~/.config/arch-boki-main-menu/menu.sh ~/.local/bin/boki-menu
# =============================================================================

set -uo pipefail

# ---------------------------------------------------------------------------
# Core path variables — everything derives from these three
# ---------------------------------------------------------------------------
BOKI_USER="$(whoami)"
BOKI_HOME="/home/${BOKI_USER}"
BOKI_CONFIG="${BOKI_HOME}/.config/arch-boki-main-menu"
CHADWM_DIR="${BOKI_HOME}/.config/chadwm-boki/chadwm-boki"

# ---------------------------------------------------------------------------
# User-tuneable settings — override in $BOKI_CONFIG/menu.conf if present
# ---------------------------------------------------------------------------
TERMINAL="${TERMINAL:-alacritty}"
EDITOR="${EDITOR:-nvim}"
MENU_WIDTH="${MENU_WIDTH:-35}"
LAUNCHER_THEME="${LAUNCHER_THEME:-${BOKI_CONFIG}/menu/arch-boki-menu-everforest-transparent.rasi}"

# Detect installed browser
if [[ -z "${BROWSER:-}" ]]; then
    for _b in brave-browser firefox chromium helium-browser vivaldi qutebrowser; do
        if command -v "$_b" &>/dev/null; then
            BROWSER="$_b"
            break
        fi
    done
    BROWSER="${BROWSER:-xdg-open}"
fi

# Detect AUR helper — if both installed, ask user to pick
_detect_aur_helper() {
    local _has_yay _has_paru
    command -v yay  &>/dev/null && _has_yay=1  || _has_yay=0
    command -v paru &>/dev/null && _has_paru=1 || _has_paru=0

    if (( _has_yay && _has_paru )); then
        local _pick
        _pick=$(printf "yay\nparu" | rofi -dmenu -p "AUR helper" \
            -no-fixed-num-lines -no-show-match 2>/dev/null) || true
        AUR_HELPER="${_pick:-yay}"
    elif (( _has_yay )); then
        AUR_HELPER="yay"
    elif (( _has_paru )); then
        AUR_HELPER="paru"
    else
        AUR_HELPER=""
    fi
}

# Rofi theme
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROFI_THEME="${ROFI_THEME:-${BOKI_CONFIG}/menu/arch-boki-menu-everforest-transparent.rasi}"

# Source user overrides
[[ -f "${BOKI_CONFIG}/menu.conf" ]] && source "${BOKI_CONFIG}/menu.conf"

# User extension — can override any function below
USER_EXTENSION="${BOKI_CONFIG}/menu/menu-extension.sh"

# Back-navigation flag
BACK_TO_EXIT=false

go_back() { :; }

# ---------------------------------------------------------------------------
# Core helper: rofi menu renderer
# ---------------------------------------------------------------------------
menu() {
    local prompt="$1"
    local options="$2"
    local extra="${3:-}"

    local theme_arg=()
    [[ -n "$ROFI_THEME" ]] && theme_arg=(-theme "$ROFI_THEME")

    local choice
    choice=$(echo -e "$options" | rofi -dmenu \
        -no-config \
        -p "$prompt" \
        -no-show-match \
        -no-fixed-num-lines \
        -cycle \
        "${theme_arg[@]}" \
        ${extra} \
        2>/dev/null) || true

    if [[ -z "$choice" ]]; then
        go_back
        return 1
    fi

    echo "$choice"
}

# ---------------------------------------------------------------------------
# Terminal helpers
# ---------------------------------------------------------------------------
terminal() {
    setsid "$TERMINAL" "$@" >/dev/null 2>&1 &
    disown
}

present_terminal() {
    local cmd="$*"
    setsid "$TERMINAL" \
        --class BokiPresent \
        -e bash -c "
            echo
            printf '  \e[1m%s\e[0m\n\n' 'arch-boki'
            ${cmd}
            echo
            printf '  Press any key to close...'
            read -n1 -s
        " >/dev/null 2>&1 &
    disown
}

plain_terminal() {
    local cmd="$*"
    setsid "$TERMINAL" \
        --class BokiPresent \
        -e bash -c "
            echo
            printf '  \e[1m%s\e[0m\n\n' 'arch-boki'
            ${cmd}
        " >/dev/null 2>&1 &
    disown
}

edit_in_editor() {
    local file="$1"
    notify-send -t 2000 "arch-boki" "Editing $(basename "$file")"
    setsid "$TERMINAL" \
        --class BokiPresent \
        -e bash -c "${EDITOR} '${file}'" >/dev/null 2>&1 &
    disown
}

open_in_thunar() {
    local path="$1"
    setsid thunar "$path" >/dev/null 2>&1 &
    disown
}

# ---------------------------------------------------------------------------
# Package helpers
# ---------------------------------------------------------------------------
install_pkg() {
    local name="$1"
    local pkgs="$2"
    present_terminal "echo 'Installing ${name}...'; sudo pacman -S --needed --noconfirm ${pkgs} && notify-send 'arch-boki' '${name} installed.' || notify-send -u critical 'arch-boki' 'Install failed.'"
}

aur_install_pkg() {
    local name="$1"
    local pkg="$2"
    if [[ -z "${AUR_HELPER:-}" ]]; then
        _detect_aur_helper
    fi
    if [[ -z "$AUR_HELPER" ]]; then
        notify-send -u critical "arch-boki" "No AUR helper found. Install yay or paru first."
        return 1
    fi
    present_terminal "echo 'Installing ${name} from AUR...'; ${AUR_HELPER} -S --noconfirm ${pkg} && notify-send 'arch-boki' '${name} installed.' || notify-send -u critical 'arch-boki' 'AUR install failed.'"
}

remove_pkg() {
    local name="$1"
    local pkgs="$2"
    present_terminal "echo 'Removing ${name}...'; sudo pacman -Rns --noconfirm ${pkgs} && notify-send 'arch-boki' '${name} removed.' || notify-send -u critical 'arch-boki' 'Remove failed.'"
}

# ===========================================================================
# LEARN
# ===========================================================================
show_learn_menu() {
    case $(menu "Learn" " Keybindings\n About Shells\n Arch Wiki\n Chadwm Source\n Neovim\n Man Pages") in
        *Keybindings*)   "${BOKI_CONFIG}/scripts/show-keys-python.sh" ;;
        *"About Shells"*) show_learn_shells_menu ;;
        *"Arch Wiki"*)   setsid "$BROWSER" "https://wiki.archlinux.org" >/dev/null 2>&1 & disown ;;
        *"Chadwm"*)      setsid "$BROWSER" "https://github.com/erikdubois/ohmychadwm" >/dev/null 2>&1 & disown ;;
        *Neovim*)        setsid "$BROWSER" "https://www.lazyvim.org/keymaps" >/dev/null 2>&1 & disown ;;
        *"Man Pages"*)   present_terminal "man -k . &>/dev/null || { echo 'Building man database...'; sudo mandb; }; man -k . | fzf --preview 'man {1}' | awk '{print \$1}' | xargs -r man" ;;
        *)               return 1 ;;
    esac
}

show_learn_shells_menu() {
    case $(menu "About Shells" " Bash\n Bash Aliases\n Fish\n Starship") in
        *Bash*)         setsid "$BROWSER" "https://devhints.io/bash" >/dev/null 2>&1 & disown ;;
        *"Bash Aliases"*) setsid "$BROWSER" "https://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html" >/dev/null 2>&1 & disown ;;
        *Fish*)         setsid "$BROWSER" "https://fishshell.com/docs/current/" >/dev/null 2>&1 & disown ;;
        *Starship*)     setsid "$BROWSER" "https://starship.rs/config/" >/dev/null 2>&1 & disown ;;
        *)              return 1 ;;
    esac
}

# ===========================================================================
# SEARCH
# ===========================================================================
show_search_menu() {
    case $(menu "Search" " Google\n DuckDuckGo\n Wikipedia\n BokiWebHome\n ArchLinux") in
        *Google*)      _search_browser "https://www.google.com/search?q=" ;;
        *DuckDuckGo*)  _search_browser "https://duckduckgo.com/?q=" ;;
        *Wikipedia*)   _search_browser "https://en.wikipedia.org/wiki/Special:Search?search=" ;;
        *BokiWebHome*) setsid "$BROWSER" "about:home" >/dev/null 2>&1 & disown ;;
        *ArchLinux*)   _search_browser "https://archlinux.org/packages/?q=" ;;
        *)             return 1 ;;
    esac
}

_search_browser() {
    local base_url="$1"
    local query
    query=$(rofi -no-config -dmenu -p "Search…" -no-fixed-num-lines 2>/dev/null) || return 1
    [[ -z "$query" ]] && return 1
    local encoded
    encoded=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$query" 2>/dev/null || echo "$query")
    setsid "$BROWSER" "${base_url}${encoded}" >/dev/null 2>&1 &
    disown
}

# ===========================================================================
# TRIGGER
# ===========================================================================
show_trigger_menu() {
    while true; do
        case $(menu "Trigger" " Capture\n Toggle\n Power Profiles\n Keybindings") in
            *Capture*)        show_capture_menu       || continue; return 0 ;;
            *Toggle*)         show_toggle_menu        || continue; return 0 ;;
            *"Power Profiles"*) show_power_profiles_menu || continue; return 0 ;;
            *Keybindings*)    "${BOKI_CONFIG}/scripts/show-keys-python.sh"; return 0 ;;
            *)                return 1 ;;
        esac
    done
}

show_capture_menu() {
    while true; do
        case $(menu "Capture" " Screenshot\n Screenshot → clipboard\n Screenshot region\n Simplescreenrecorder\n Colour picker") in
            *"Screenshot →"*)      _screenshot_clipboard; return 0 ;;
            *"Screenshot region"*) _screenshot_region;    return 0 ;;
            *Screenshot*)          _screenshot_smart;     return 0 ;;
            *Simple*)              _launch_screenrecorder; return 0 ;;
            *"Colour picker"*)     _colour_picker;        return 0 ;;
            *)                     return 1 ;;
        esac
    done
}

_screenshot_smart() {
    local dir="${BOKI_HOME}/Pictures/Screenshots"
    mkdir -p "$dir"
    local file="${dir}/$(date +%Y-%m-%d_%H-%M-%S).png"
    maim "$file"
    xclip -selection clipboard -t image/png < "$file"
    notify-send -t 4000 "arch-boki" "Screenshot saved: $(basename "$file")"
}

_screenshot_clipboard() {
    maim | xclip -selection clipboard -t image/png
    notify-send -t 2000 "Screenshot" "Copied to clipboard"
}

_screenshot_region() {
    local dir="${BOKI_HOME}/Pictures/Screenshots"
    mkdir -p "$dir"
    local file="${dir}/$(date +%Y-%m-%d_%H-%M-%S).png"
    maim -s "$file"
    xclip -selection clipboard -t image/png < "$file"
    notify-send -t 3000 "Region screenshot" "Saved & copied to clipboard"
}

_colour_picker() {
    if command -v xcolor &>/dev/null; then
        local color
        color=$(xcolor)
        echo -n "$color" | xclip -selection clipboard
        notify-send -t 0 "Colour picked" "$color (copied to clipboard)"
    else
        notify-send -u critical "arch-boki" "xcolor not installed. Run: sudo pacman -S xcolor"
    fi
}

_launch_screenrecorder() {
    if ! command -v simplescreenrecorder &>/dev/null; then
        notify-send "arch-boki" "Installing SimpleScreenRecorder..."
        sudo pacman -S --needed --noconfirm simplescreenrecorder
    fi
    setsid simplescreenrecorder &>/dev/null &
    disown
}

show_toggle_menu() {
    local _nightlight_state="Enable"
    local _autolock_state="Enable"
    local _picom_state="Start"
    local _fastcompmgr_state="Start"

    [[ -f "${BOKI_HOME}/.local/state/arch-boki/toggles/nightlight-on" ]] && _nightlight_state="Disable"
    [[ -f "${BOKI_HOME}/.local/state/arch-boki/toggles/autolock-on"   ]] && _autolock_state="Disable"
    pgrep -x picom       &>/dev/null && _picom_state="Stop"
    pgrep -x fastcompmgr &>/dev/null && _fastcompmgr_state="Stop"

    case $(menu "Toggle" "${_nightlight_state} night light\n ${_autolock_state} auto-lock\n ${_picom_state} picom\n ${_fastcompmgr_state} fastcompmgr") in
        *"night light"*) _toggle_nightlight ;;
        *"auto-lock"*)   _toggle_autolock ;;
        *picom*)         _toggle_picom ;;
        *fastcompmgr*)   _toggle_fastcompmgr ;;
        *)               return 1 ;;
    esac
}

_toggle_picom() {
    if pgrep -x picom &>/dev/null; then
        pkill picom && notify-send "Picom" "Stopped"
    else
        if pgrep -x fastcompmgr &>/dev/null; then
            pkill fastcompmgr 2>/dev/null
            local _i=0; while pgrep -x fastcompmgr &>/dev/null && (( _i++ < 30 )); do sleep 0.1; done
        fi
        setsid picom --config "${BOKI_CONFIG}/picom/picom.conf" -b &>/dev/null &
        disown
        notify-send "Picom" "Started"
    fi
}

_toggle_fastcompmgr() {
    if pgrep -x fastcompmgr &>/dev/null; then
        pkill fastcompmgr && notify-send "Fastcompmgr" "Stopped"
    else
        if pgrep -x picom &>/dev/null; then
            pkill picom 2>/dev/null
            local _i=0; while pgrep -x picom &>/dev/null && (( _i++ < 30 )); do sleep 0.1; done
        fi
        setsid fastcompmgr -c &>/dev/null &
        disown
        notify-send "Fastcompmgr" "Started"
    fi
}

_toggle_nightlight() {
    local state_file="${BOKI_HOME}/.local/state/arch-boki/toggles/nightlight-on"
    mkdir -p "$(dirname "$state_file")"
    if [[ -f "$state_file" ]]; then
        pkill redshift 2>/dev/null; rm -f "$state_file"
        notify-send "Night light" "Disabled"
    else
        if ! command -v redshift &>/dev/null; then
            notify-send "arch-boki" "Installing redshift..."
            sudo pacman -S --needed --noconfirm redshift
        fi
        touch "$state_file"
        redshift -O 4000 &>/dev/null &
        disown
        notify-send "Night light" "Enabled (4000K)"
    fi
}

_toggle_autolock() {
    local state_file="${BOKI_HOME}/.local/state/arch-boki/toggles/autolock-on"
    mkdir -p "$(dirname "$state_file")"
    if [[ -f "$state_file" ]]; then
        pkill xautolock 2>/dev/null; rm -f "$state_file"
        notify-send "Auto-lock" "Disabled"
    else
        touch "$state_file"
        xautolock -time 10 -locker betterlockscreen -l dim -- --time-str="%H:%M" &>/dev/null &
        disown
        notify-send "Auto-lock" "Enabled (10 min)"
    fi
}

show_power_profiles_menu() {
    if ! command -v powerprofilesctl &>/dev/null; then
        notify-send -u critical "arch-boki" "power-profiles-daemon not installed. Run: sudo pacman -S power-profiles-daemon"
        return 1
    fi
    local current
    current=$(powerprofilesctl get 2>/dev/null || echo "")
    local profiles
    profiles=$(powerprofilesctl list 2>/dev/null | grep -oP '^\s*\K\S+(?=:)' | tr '\n' '\n')
    local chosen
    chosen=$(echo -e "$profiles" | rofi -no-config -dmenu -p "Power profile (current: ${current})" \
        -no-fixed-num-lines 2>/dev/null) || return 1
    [[ -z "$chosen" ]] && return 1
    powerprofilesctl set "$chosen"
    notify-send "arch-boki" "Power profile set to: ${chosen}"
}

# ===========================================================================
# STYLE
# ===========================================================================
show_style_menu() {
    while true; do
        case $(menu "Style" " Chadwm-Boki\n Terminals\n Menu Launcher\n System-Theme\n Wallpaper Changer\n Font") in
            *"Chadwm-Boki"*)    show_chadwm_boki_menu   || continue; return 0 ;;
            *Terminals*)        show_terminals_menu      || continue; return 0 ;;
            *"Menu Launcher"*)  show_menu_launcher_menu  || continue; return 0 ;;
            *"System-Theme"*)   show_system_theme_menu   || continue; return 0 ;;
            *"Wallpaper"*)      show_wallpaper_menu      || continue; return 0 ;;
            *Font*)             show_font_menu           || continue; return 0 ;;
            *)                  return 1 ;;
        esac
    done
}

show_chadwm_boki_menu() {
    while true; do
        case $(menu "Chadwm-Boki" " Choose theme\n Create theme from BG\n Delete theme\n Customise\n Random theme\n Open config folder") in
            *"Choose theme"*)       show_theme_menu          || continue; return 0 ;;
            *"Create theme"*)
                setsid "$TERMINAL" -e bash -c \
                    "${BOKI_CONFIG}/scripts/generate-chadwm-theme.sh; exec bash" \
                    >/dev/null 2>&1 &
                return 0 ;;
            *"Delete theme"*)       show_delete_theme_menu   || continue; return 0 ;;
            *Customise*)            show_customise_menu      || continue; return 0 ;;
            *"Random theme"*)       _random_theme; return 0 ;;
            *"Open config folder"*) open_in_thunar "${CHADWM_DIR}"; return 0 ;;
            *)                      return 1 ;;
        esac
    done
}

show_theme_menu() {
    local themes_dir="${CHADWM_DIR}/themes"

    [[ ! -d "$themes_dir" ]] && { notify-send "arch-boki" "No themes directory found"; return 1; }

    local theme_list
    theme_list=$(ls -1 "${themes_dir}"/*.h 2>/dev/null | xargs -n1 basename | sed 's/\.h$//')
    [[ -z "$theme_list" ]] && { notify-send "arch-boki" "No themes found"; return 1; }

    local chosen
    chosen=$(menu "Choose theme" "$theme_list") || return 1
    [[ -z "$chosen" ]] && return 1
    _apply_theme "$chosen"
    notify-send "arch-boki" "Theme '${chosen}' applied — rebuilding..."
}

_random_theme() {
    local config="${CHADWM_DIR}/config.def.h"
    local -a themes
    mapfile -t themes < <(grep -oP '(?<=themes/)[^"]+(?=\.h")' "$config")
    local current
    current=$(grep -oP '(?<=#include "themes/)[^"]+(?=\.h")' "$config" | head -1)
    local -a candidates=()
    for t in "${themes[@]}"; do
        [[ "$t" != "$current" ]] && candidates+=("$t")
    done
    local pick="${candidates[RANDOM % ${#candidates[@]}]}"
    notify-send "arch-boki" "Random theme: $pick"
    _apply_theme "$pick"
}

_apply_theme() {
    local theme="$1"
    local config="${CHADWM_DIR}/config.def.h"
    [[ ! -f "${CHADWM_DIR}/themes/${theme}.h" ]] && {
        notify-send -u critical "arch-boki" "Theme '${theme}' not found"
        return 1
    }
    # Comment out all active theme includes
    sed -i 's|^#include "themes/\(.*\)\.h"|//#include "themes/\1.h"|' "$config"
    # Activate target theme: uncomment if already listed, otherwise insert after last theme line
    if grep -q "^//#include \"themes/${theme}\.h\"" "$config"; then
        sed -i "s|^//#include \"themes/${theme}\.h\"|#include \"themes/${theme}.h\"|" "$config"
    else
        python3 - "$config" "$theme" <<'PYEOF'
import sys, re
config, theme = sys.argv[1], sys.argv[2]
with open(config) as f:
    lines = f.readlines()
last_idx = -1
for i, line in enumerate(lines):
    if re.match(r'\s*//#include\s+"themes/', line):
        last_idx = i
ins = f'#include "themes/{theme}.h"\n'
if last_idx >= 0:
    lines.insert(last_idx + 1, ins)
else:
    lines.append(ins)
with open(config, 'w') as f:
    f.writelines(lines)
PYEOF
    fi
    local xres="${CHADWM_DIR}/themes/${theme}.Xresources"
    [[ -f "$xres" ]] && xrdb -merge "$xres"
    local theme_wp="${BOKI_CONFIG}/wallpapers/${theme}.jpg"
    [[ -f "$theme_wp" ]] && feh --bg-fill "$theme_wp"
    (cd "${CHADWM_DIR}" && \
        setsid "$TERMINAL" -e bash -c 'bash rebuild.sh; exec bash' >/dev/null 2>&1 &)
    notify-send "arch-boki" "Theme '${theme}' applied"
}

show_delete_theme_menu() {
    local themes_dir="${CHADWM_DIR}/themes"
    local config="${CHADWM_DIR}/config.def.h"
    local -a BUILTIN
    mapfile -t BUILTIN < <(grep -oP '(?<=themes/)[^"]+(?=\.h")' "$config")

    local custom_list=""
    for f in "$themes_dir"/*.h; do
        local name; name=$(basename "$f" .h)
        local is_builtin=0
        for b in "${BUILTIN[@]}"; do [[ "$name" == "$b" ]] && is_builtin=1 && break; done
        [[ $is_builtin -eq 0 ]] && custom_list+="$name\n"
    done
    custom_list="${custom_list%\\n}"

    if [[ -z "$custom_list" ]]; then
        notify-send "arch-boki" "No custom themes to delete"
        return 1
    fi

    local chosen
    chosen=$(menu "Delete theme" "$custom_list") || return 1
    local confirm
    confirm=$(menu "Delete '${chosen}'?" " Yes, delete it\n Cancel") || return 1
    [[ "$confirm" == *"Cancel"* ]] && return 1

    local active
    active=$(grep -oP '(?<=#include "themes/)[^"]+(?=\.h")' "$config" | head -1)
    sed -i "/[#/]*#\?include \"themes\/${chosen}\.h\"/d" "$config"
    rm -f "${themes_dir}/${chosen}.h"
    for ext in jpg jpeg png webp; do
        rm -f "${BOKI_CONFIG}/wallpapers/${chosen}.${ext}"
    done
    if [[ "$active" == "$chosen" ]]; then
        notify-send "arch-boki" "Active theme deleted — switching to default"
        _apply_theme "kanagawa"
    else
        notify-send "arch-boki" "Theme '${chosen}' deleted"
    fi
}

show_customise_menu() {
    while true; do
        case $(menu "Customise" " Tags\n Border\n Gaps\n Bar padding\n Bar position\n Smart gaps\n Hide systray\n New window\n Launcher icons\n Master area\n Back to default") in
            *Tags*)             show_tags_menu         || continue; return 0 ;;
            *Border*)           show_border_menu       || continue; return 0 ;;
            *Gaps*)             show_gaps_menu         || continue; return 0 ;;
            *"Bar padding"*)    show_barpad_menu       || continue; return 0 ;;
            *"Bar position"*)   show_bar_menu          || continue; return 0 ;;
            *"Smart gaps"*)     show_smartgaps_menu    || continue; return 0 ;;
            *"Hide systray"*)   show_systray_menu      || continue; return 0 ;;
            *"New window"*)     show_newwindow_menu    || continue; return 0 ;;
            *"Launcher icons"*) show_launchers_menu    || continue; return 0 ;;
            *"Master area"*)    show_mfact_menu        || continue; return 0 ;;
            *"Back to default"*) _customise_reset_defaults; return 0 ;;
            *)                  return 1 ;;
        esac
    done
}

show_tags_menu() {
    local chosen
    chosen=$(menu "Tags" "default tags\nArabic numbers\nRoman numbers\nPowerline\nWebdings\nJapanese numbers\nAlphabetic\nEmoji\nGeometric shapes\nChinese numbers") || return 1
    local config="${CHADWM_DIR}/config.def.h"
    python3 - "$chosen" "$config" <<'PYEOF'
import sys, re
chosen = sys.argv[1]; config = sys.argv[2]
with open(config) as f: content = f.read()
content = re.sub(r'^(static char \*tags\[\])', r'//\1', content, flags=re.MULTILINE)
pattern = r'(//' + re.escape(chosen) + r'\n)//(static char \*tags\[\])'
new_content, n = re.subn(pattern, r'\1\2', content)
if n == 0: print(f"No tags entry found for '{chosen}'", file=sys.stderr); sys.exit(1)
with open(config, 'w') as f: f.write(new_content)
PYEOF
    (cd "${CHADWM_DIR}" && \
        setsid "$TERMINAL" -e bash -c './rebuild.sh; exec bash' >/dev/null 2>&1 &)
    notify-send "arch-boki" "Tags set to '${chosen}'"
}

show_border_menu() {
    local current
    current=$(grep -oP 'borderpx\s*=\s*\K[0-9]+' "${CHADWM_DIR}/config.def.h")
    local chosen
    chosen=$(menu "Border (current: ${current}px)" "0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10") || return 1
    sed -i "s/static const unsigned int borderpx\s*=\s*[0-9]\+/static const unsigned int borderpx  = ${chosen}/" \
        "${CHADWM_DIR}/config.def.h"
    (cd "${CHADWM_DIR}" && \
        setsid "$TERMINAL" -e bash -c './rebuild.sh; exec bash' >/dev/null 2>&1 &)
    notify-send "arch-boki" "Border set to ${chosen}px"
}

show_gaps_menu() {
    local current
    current=$(grep -oP 'gappih\s*=\s*\K[0-9]+' "${CHADWM_DIR}/config.def.h")
    local chosen
    chosen=$(menu "Gaps (current: ${current}px)" "0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10") || return 1
    local config="${CHADWM_DIR}/config.def.h"
    sed -i "s/\(gappih\s*=\s*\)[0-9]\+/\1${chosen}/" "$config"
    sed -i "s/\(gappiv\s*=\s*\)[0-9]\+/\1${chosen}/" "$config"
    sed -i "s/\(gappoh\s*=\s*\)[0-9]\+/\1${chosen}/" "$config"
    sed -i "s/\(gappov\s*=\s*\)[0-9]\+/\1${chosen}/" "$config"
    (cd "${CHADWM_DIR}" && \
        setsid "$TERMINAL" -e bash -c './rebuild.sh; exec bash' >/dev/null 2>&1 &)
    notify-send "arch-boki" "Gaps set to ${chosen}px"
}

show_barpad_menu() {
    local config="${CHADWM_DIR}/config.def.h"
    while true; do
        local cv ch
        cv=$(grep -oP 'vertpadbar\s*=\s*\K[0-9]+' "$config")
        ch=$(grep -oP 'horizpadbar\s*=\s*\K[0-9]+' "$config")
        case $(menu "Bar padding  vert:${cv}  horiz:${ch}" " Vertical padding\n Horizontal padding\n Back to default") in
            *Vertical*)
                local v
                v=$(menu "Bar vertical padding (current: ${cv})" \
                    "0\n2\n4\n6\n8\n10\n11\n12\n14\n16\n18\n20") || continue
                sed -i "s/\(static const int vertpadbar\s*=\s*\)[0-9]\+/\1${v}/" "$config"
                (cd "${CHADWM_DIR}" && \
                    setsid "$TERMINAL" -e bash -c './rebuild.sh; exec bash' >/dev/null 2>&1 &)
                return 0 ;;
            *Horizontal*)
                local h
                h=$(menu "Bar horizontal padding (current: ${ch})" \
                    "0\n2\n4\n5\n6\n8\n10\n12\n14\n16\n18\n20") || continue
                sed -i "s/\(static const int horizpadbar\s*=\s*\)[0-9]\+/\1${h}/" "$config"
                (cd "${CHADWM_DIR}" && \
                    setsid "$TERMINAL" -e bash -c './rebuild.sh; exec bash' >/dev/null 2>&1 &)
                return 0 ;;
            *"Back to default"*)
                sed -i "s/\(static const int vertpadbar\s*=\s*\)[0-9]\+/\111/" "$config"
                sed -i "s/\(static const int horizpadbar\s*=\s*\)[0-9]\+/\15/" "$config"
                (cd "${CHADWM_DIR}" && \
                    setsid "$TERMINAL" -e bash -c './rebuild.sh; exec bash' >/dev/null 2>&1 &)
                return 0 ;;
            *) return 1 ;;
        esac
    done
}

show_bar_menu() {
    local config="${CHADWM_DIR}/config.def.h"
    local current
    current=$(grep -oP 'topbar\s*=\s*\K[01]' "$config")
    local current_label="top"; [[ "$current" == "0" ]] && current_label="bottom"
    local chosen
    chosen=$(menu "Bar position (current: ${current_label})" "top\nbottom") || return 1
    local value=1; [[ "$chosen" == "bottom" ]] && value=0
    sed -i "s/\(static const int topbar\s*=\s*\)[01]/\1${value}/" "$config"
    (cd "${CHADWM_DIR}" && \
        setsid "$TERMINAL" -e bash -c './rebuild.sh; exec bash' >/dev/null 2>&1 &)
    notify-send "arch-boki" "Bar moved to ${chosen}"
}

show_smartgaps_menu() {
    local config="${CHADWM_DIR}/config.def.h"
    local current
    current=$(grep -oP 'smartgaps\s*=\s*\K[01]' "$config")
    local current_label="no"; [[ "$current" == "1" ]] && current_label="yes"
    local chosen
    chosen=$(menu "Smart gaps (current: ${current_label})" "yes\nno") || return 1
    local value=0; [[ "$chosen" == "yes" ]] && value=1
    sed -i "s/\(static const int smartgaps\s*=\s*\)[01]/\1${value}/" "$config"
    (cd "${CHADWM_DIR}" && \
        setsid "$TERMINAL" -e bash -c './rebuild.sh; exec bash' >/dev/null 2>&1 &)
    notify-send "arch-boki" "Smart gaps set to ${chosen}"
}

show_systray_menu() {
    local config="${CHADWM_DIR}/config.def.h"
    local current
    current=$(grep -oP 'showsystray\s*=\s*\K[01]' "$config")
    local current_label="no"; [[ "$current" == "1" ]] && current_label="yes"
    local chosen
    chosen=$(menu "Hide systray (currently hidden: ${current_label})" "yes\nno") || return 1
    local value=1; [[ "$chosen" == "yes" ]] && value=0
    sed -i "s/\(static const int showsystray\s*=\s*\)[01]/\1${value}/" "$config"
    (cd "${CHADWM_DIR}" && \
        setsid "$TERMINAL" -e bash -c './rebuild.sh; exec bash' >/dev/null 2>&1 &)
    notify-send "arch-boki" "Systray hidden: ${chosen}"
}

show_newwindow_menu() {
    local config="${CHADWM_DIR}/config.def.h"
    local current
    current=$(grep -oP 'new_window_attach_on_end\s*=\s*\K[01]' "$config")
    local current_label="on the front"; [[ "$current" == "1" ]] && current_label="on the end"
    local chosen
    chosen=$(menu "New window (current: ${current_label})" "on the front\non the end") || return 1
    local value=0; [[ "$chosen" == "on the end" ]] && value=1
    sed -i "s/\(new_window_attach_on_end\s*=\s*\)[01]/\1${value}/" "$config"
    (cd "${CHADWM_DIR}" && \
        setsid "$TERMINAL" -e bash -c './rebuild.sh; exec bash' >/dev/null 2>&1 &)
    notify-send "arch-boki" "New windows open ${chosen}"
}

show_mfact_menu() {
    local config="${CHADWM_DIR}/config.def.h"
    local current
    current=$(grep -oP 'mfact\s*=\s*\K[0-9.]+' "$config")
    local current_pct
    current_pct=$(printf "%.0f" "$(echo "$current * 100" | bc)")
    local chosen
    chosen=$(menu "Master area (current: ${current_pct}%)" \
        "10%\n20%\n30%\n40%\n50%\n60%\n70%\n80%\n90%") || return 1
    local pct="${chosen/\%/}"
    local value; value=$(printf "0.%02d" "$pct")
    sed -i "s/\(static const float mfact\s*=\s*\)[0-9.]*/\1${value}/" "$config"
    (cd "${CHADWM_DIR}" && \
        setsid "$TERMINAL" -e bash -c './rebuild.sh; exec bash' >/dev/null 2>&1 &)
    notify-send "arch-boki" "Master area set to ${chosen}"
}

show_launchers_menu() {
    local config="${CHADWM_DIR}/config.def.h"
    local -a names=(discord firefox brave opera mintstick pavucontrol telegram vivaldi)
    local -A labels=(
        [discord]="Discord" [firefox]="Firefox" [brave]="Brave" [opera]="Opera"
        [mintstick]="Mintstick" [pavucontrol]="Pavucontrol"
        [telegram]="Telegram" [vivaldi]="Vivaldi"
    )
    while true; do
        local options=""
        for name in "${names[@]}"; do
            if grep -qP "^\s*\{\s*${name}," "$config"; then
                options+="✓ ${labels[$name]}\n"
            else
                options+="✗ ${labels[$name]}\n"
            fi
        done
        options+=" Apply & rebuild"
        local chosen
        chosen=$(menu "Launcher icons" "$options") || return 1
        if [[ "$chosen" == *"Apply"* ]]; then
            (cd "${CHADWM_DIR}" && \
                setsid "$TERMINAL" -e bash -c './rebuild.sh; exec bash' >/dev/null 2>&1 &)
            notify-send "arch-boki" "Launcher icons updated"
            return 0
        fi
        for name in "${names[@]}"; do
            if [[ "$chosen" == *"${labels[$name]}"* ]]; then
                if grep -qP "^\s*\{\s*${name}," "$config"; then
                    sed -i "s|^\(\s*\){ ${name},|\1//{ ${name},|" "$config"
                else
                    sed -i "s|^\(\s*\)//{ ${name},|\1{ ${name},|" "$config"
                fi
                break
            fi
        done
    done
}

_customise_reset_defaults() {
    local config="${CHADWM_DIR}/config.def.h"
    local default="${CHADWM_DIR}/config.def.h.default"
    present_terminal "bash -c '
        if [[ ! -f \"$default\" ]]; then echo \"ERROR: default not found.\"; exit 1; fi
        echo \"Reset chadwm config to default\"
        echo \"\"
        read -rp \"Continue? [y/N] \" ans
        [[ \"\$ans\" =~ ^[Yy]\$ ]] || { echo \"Cancelled.\"; exit 0; }
        ts=\$(date +%Y%m%d-%H%M%S)
        cp \"$config\" \"${config}.\${ts}\"
        cp \"$default\" \"$config\"
        echo \"Config restored.\"
        cd \"${CHADWM_DIR}\" && bash rebuild.sh
    '"
}

show_font_menu() {
    local config="${CHADWM_DIR}/config.def.h"
    local active_theme
    active_theme=$(grep -oP '(?<=#include "themes/)[^"]+(?=\.h")' "$config" | head -1)
    local theme_file="${CHADWM_DIR}/themes/${active_theme}.h"
    present_terminal "bash -c '
        family=\$(fc-list : family \
            | sed \"s/,.*//\" \
            | sort -uf \
            | fzf --prompt=\"Font family > \" --height=40% --layout=reverse --border 2>/dev/null) || exit 0
        [[ -z \"\$family\" ]] && exit 0
        echo -e \"\nFont size? [default 13]:\"
        read -rp \"> \" size
        [[ \"\$size\" =~ ^[0-9]+\$ ]] || size=13
        for f in \"${theme_file}\" \"${config}\"; do
            sed -i \"s|#define THEME_FONT \\\"[^\\\"]*\\\"|#define THEME_FONT    \\\"\$family\\\"|\" \"\$f\"
            sed -i \"s|#define THEME_FONTSIZE [0-9]*|#define THEME_FONTSIZE    \$size|\" \"\$f\"
        done
        notify-send \"arch-boki\" \"Font: \$family \$size — rebuilding...\"
        cd \"${CHADWM_DIR}\" && bash rebuild.sh
    '"
}

show_terminals_menu() {
    while true; do
        case $(menu "Terminals" " Alacritty config\n Kitty config\n Ghostty config\n WezTerm config") in
            *Alacritty*) edit_in_editor "${BOKI_HOME}/.config/alacritty/alacritty.toml"; return 0 ;;
            *Kitty*)     edit_in_editor "${BOKI_HOME}/.config/kitty/kitty.conf"; return 0 ;;
            *Ghostty*)   edit_in_editor "${BOKI_HOME}/.config/ghostty/config"; return 0 ;;
            *WezTerm*)   edit_in_editor "${BOKI_HOME}/.config/wezterm/wezterm.lua"; return 0 ;;
            *)           return 1 ;;
        esac
    done
}

show_menu_launcher_menu() {
    local launchers_dir="${BOKI_CONFIG}/scripts/launchers"
    while true; do
        case $(menu "Menu Launcher" " Main Menu Theme\n App Launcher Theme\n Rofi\n Launcher\n Launcher3\n Launcher-Aditaya\n Launcher-Category\n Launchers-Rofi\n Powermenu\n Powermenu2\n Rofi-Christitustech\n Rofi-Siduck\n Rofi-Xero-Linux") in
            *"Main Menu Theme"*)   show_main_menu_theme_menu;  return 0 ;;
            *"App Launcher Theme"*) show_app_launcher_theme_menu; return 0 ;;
            *Rofi-Christitustech*) bash "${launchers_dir}/rofi-christitustech.sh"; return 0 ;;
            *Rofi-Siduck*)         bash "${launchers_dir}/rofi-siduck.sh"; return 0 ;;
            *Rofi-Xero-Linux*)     bash "${launchers_dir}/rofi-xero-linux.sh"; return 0 ;;
            *Rofi*)                bash "${launchers_dir}/rofi.sh"; return 0 ;;
            *Launcher-Aditaya*)    bash "${launchers_dir}/launcher-aditaya.sh"; return 0 ;;
            *Launcher-Category*)   bash "${launchers_dir}/launcher-category.sh"; return 0 ;;
            *Launchers-Rofi*)      bash "${launchers_dir}/launchers-rofi.sh"; return 0 ;;
            *Launcher3*)           bash "${launchers_dir}/launcher3.sh"; return 0 ;;
            *Launcher*)            bash "${launchers_dir}/launcher.sh"; return 0 ;;
            *Powermenu2*)          bash "${launchers_dir}/powermenu2.sh"; return 0 ;;
            *Powermenu*)           bash "${launchers_dir}/powermenu.sh"; return 0 ;;
            *)                     return 1 ;;
        esac
    done
}

show_main_menu_theme_menu() {
    local conf="${BOKI_CONFIG}/menu.conf"
    local current_label="(using default)"
    [[ -n "$ROFI_THEME" ]] && current_label="$(basename "$ROFI_THEME")"
    local -a _paths
    mapfile -t _paths < <(find "${_SCRIPT_DIR}/menu" \
        -name "*.rasi" 2>/dev/null | sort)
    local _names
    _names=$(printf '%s\n' "${_paths[@]}" | xargs -n1 basename)
    local _chosen_name _chosen_path
    _chosen_name=$(echo "$_names" | \
        rofi -no-config -dmenu -p "Main menu theme (current: ${current_label})" \
        -no-fixed-num-lines 2>/dev/null) || return 1
    [[ -z "$_chosen_name" ]] && return 1
    _chosen_path=$(printf '%s\n' "${_paths[@]}" | grep -m1 "/${_chosen_name}$")
    [[ -z "$_chosen_path" ]] && return 1
    if grep -q '^ROFI_THEME=' "$conf" 2>/dev/null; then
        sed -i "s|^ROFI_THEME=.*|ROFI_THEME=\"${_chosen_path}\"|" "$conf"
    else
        echo "ROFI_THEME=\"${_chosen_path}\"" >> "$conf"
    fi
    ROFI_THEME="$_chosen_path"
    notify-send "arch-boki" "Main menu theme set to: ${_chosen_name}"
}

show_app_launcher_theme_menu() {
    local conf="${BOKI_CONFIG}/menu.conf"
    local current_label="(picker each time)"
    [[ -n "$LAUNCHER_THEME" ]] && current_label="$(basename "$LAUNCHER_THEME")"
    local -a _paths
    mapfile -t _paths < <(find "${_SCRIPT_DIR}/menu" \
        -name "*.rasi" 2>/dev/null | sort)
    local _names
    _names=$(printf '%s\n' "${_paths[@]}" | xargs -n1 basename)
    local _chosen_name _chosen_path
    _chosen_name=$(echo "$_names" | \
        rofi -no-config -dmenu -p "App launcher theme (current: ${current_label})" \
        -no-fixed-num-lines 2>/dev/null) || return 1
    [[ -z "$_chosen_name" ]] && return 1
    _chosen_path=$(printf '%s\n' "${_paths[@]}" | grep -m1 "/${_chosen_name}$")
    [[ -z "$_chosen_path" ]] && return 1
    if grep -q '^LAUNCHER_THEME=' "$conf" 2>/dev/null; then
        sed -i "s|^LAUNCHER_THEME=.*|LAUNCHER_THEME=\"${_chosen_path}\"|" "$conf"
    else
        echo "LAUNCHER_THEME=\"${_chosen_path}\"" >> "$conf"
    fi
    LAUNCHER_THEME="$_chosen_path"
    notify-send "arch-boki" "App launcher theme set to: ${_chosen_name}"
}

show_system_theme_menu() {
    while true; do
        case $(menu "System-Theme" " GTK Theme\n Icon Theme\n Cursor Theme\n Font Settings") in
            *"GTK Theme"*)    _set_gtk_theme; return 0 ;;
            *"Icon Theme"*)   _set_icon_theme; return 0 ;;
            *"Cursor Theme"*) _set_cursor_theme; return 0 ;;
            *"Font Settings"*) _set_gtk_font; return 0 ;;
            *) return 1 ;;
        esac
    done
}

_set_gtk_theme() {
    local themes
    themes=$(find /usr/share/themes "${BOKI_HOME}/.local/share/themes" \
        -maxdepth 1 -mindepth 1 -type d 2>/dev/null | xargs -n1 basename | sort -u)
    local chosen
    chosen=$(echo "$themes" | rofi -no-config -dmenu -p "GTK Theme…" -no-fixed-num-lines 2>/dev/null) || return 1
    [[ -z "$chosen" ]] && return 1
    for cfg in "${BOKI_HOME}/.config/gtk-3.0/settings.ini" \
               "${BOKI_HOME}/.config/gtk-4.0/settings.ini"; do
        [[ -f "$cfg" ]] && sed -i "s/^gtk-theme-name=.*/gtk-theme-name=${chosen}/" "$cfg"
    done
    command -v xfconf-query &>/dev/null && \
        xfconf-query -c xsettings -p /Net/ThemeName -s "$chosen" 2>/dev/null || true
    notify-send "arch-boki" "GTK Theme set to: ${chosen}"
}

_set_icon_theme() {
    local themes
    themes=$(find /usr/share/icons "${BOKI_HOME}/.local/share/icons" \
        -maxdepth 1 -mindepth 1 -type d 2>/dev/null | xargs -n1 basename | sort -u)
    local chosen
    chosen=$(echo "$themes" | rofi -no-config -dmenu -p "Icon Theme…" -no-fixed-num-lines 2>/dev/null) || return 1
    [[ -z "$chosen" ]] && return 1
    for cfg in "${BOKI_HOME}/.config/gtk-3.0/settings.ini" \
               "${BOKI_HOME}/.config/gtk-4.0/settings.ini"; do
        [[ -f "$cfg" ]] && sed -i "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=${chosen}/" "$cfg"
    done
    command -v xfconf-query &>/dev/null && \
        xfconf-query -c xsettings -p /Net/IconThemeName -s "$chosen" 2>/dev/null || true
    notify-send "arch-boki" "Icon Theme set to: ${chosen}"
}

_set_cursor_theme() {
    local themes
    themes=$(find /usr/share/icons "${BOKI_HOME}/.local/share/icons" \
        -maxdepth 1 -mindepth 1 -type d 2>/dev/null | xargs -n1 basename | sort -u)
    local chosen
    chosen=$(echo "$themes" | rofi -no-config -dmenu -p "Cursor Theme…" -no-fixed-num-lines 2>/dev/null) || return 1
    [[ -z "$chosen" ]] && return 1
    for cfg in "${BOKI_HOME}/.config/gtk-3.0/settings.ini" \
               "${BOKI_HOME}/.config/gtk-4.0/settings.ini"; do
        [[ -f "$cfg" ]] && sed -i "s/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=${chosen}/" "$cfg"
    done
    notify-send "arch-boki" "Cursor Theme set to: ${chosen}"
}

_set_gtk_font() {
    local family
    family=$(fc-list : family | sort -u | \
        rofi -no-config -dmenu -p "GTK Font…" -no-fixed-num-lines 2>/dev/null) || return 1
    [[ -z "$family" ]] && return 1
    local size
    size=$(menu "Font size" "8\n9\n10\n11\n12\n13\n14\n15\n16") || return 1
    local font_str="${family} ${size}"
    for cfg in "${BOKI_HOME}/.config/gtk-3.0/settings.ini" \
               "${BOKI_HOME}/.config/gtk-4.0/settings.ini"; do
        [[ -f "$cfg" ]] && sed -i "s/^gtk-font-name=.*/gtk-font-name=${font_str}/" "$cfg"
    done
    notify-send "arch-boki" "GTK Font set to: ${font_str}"
}

show_wallpaper_menu() {
    local walls_dir="${BOKI_CONFIG}/wallpapers"
    local extra_dir="${BOKI_HOME}/Pictures/Wallpapers"
    local -a all_images=()

    while IFS= read -r f; do all_images+=("$f"); done \
        < <(find "$walls_dir" -maxdepth 1 -type f 2>/dev/null \
            | grep -E '\.(jpg|jpeg|png|webp)$' | sort)
    if [[ -d "$extra_dir" ]]; then
        while IFS= read -r f; do all_images+=("$f"); done \
            < <(find "$extra_dir" -maxdepth 1 -type f 2>/dev/null \
                | grep -E '\.(jpg|jpeg|png|webp)$' | sort)
    fi

    if [[ ${#all_images[@]} -eq 0 ]]; then
        notify-send "arch-boki" "No wallpaper images found"
        return 1
    fi

    local chosen
    chosen=$(printf '%s\n' "${all_images[@]}" | \
        rofi -no-config -dmenu -p "Wallpaper…" -width "$MENU_WIDTH" 2>/dev/null) || return 1
    feh --bg-fill "$chosen" && \
        notify-send "arch-boki" "Wallpaper set to '$(basename "$chosen")'"
    cp "$chosen" "${BOKI_CONFIG}/wallpapers/wallpaper.jpg"
}

# ===========================================================================
# SETUP
# ===========================================================================
show_setup_menu() {
    while true; do
        case $(menu "Setup" " Install\n Remove\n Update\n Post Install\n Maintain Configs\n Services") in
            *Install*)          show_install_menu        || continue; return 0 ;;
            *Remove*)           show_remove_menu         || continue; return 0 ;;
            *Update*)           show_update_menu         || continue; return 0 ;;
            *"Post Install"*)   show_post_install_menu   || continue; return 0 ;;
            *"Maintain Configs"*) show_maintain_configs_menu || continue; return 0 ;;
            *Services*)         show_services_menu       || continue; return 0 ;;
            *)                  return 1 ;;
        esac
    done
}

# ---------------------------------------------------------------------------
# INSTALL
# ---------------------------------------------------------------------------
show_install_menu() {
    while true; do
        case $(menu "Install" " Pacman package\n AUR package\n Web App\n TUI\n GTK Themes\n Icon Themes\n Post Install") in
            *"Pacman"*)     _install_pacman_pkg; return 0 ;;
            *"AUR"*)        _install_aur_pkg;    return 0 ;;
            *"Web App"*)    plain_terminal "${BOKI_CONFIG}/scripts/boki-webapp-install"; return 0 ;;
            *TUI*)          plain_terminal "${BOKI_CONFIG}/scripts/boki-tui-install"; return 0 ;;
            *"GTK Themes"*) show_install_gtk_themes_menu || continue; return 0 ;;
            *"Icon Themes"*) show_install_icon_themes_menu || continue; return 0 ;;
            *"Post Install"*) show_post_install_menu || continue; return 0 ;;
            *)              return 1 ;;
        esac
    done
}

_install_pacman_pkg() {
    present_terminal "pacman -Slq | fzf --multi --preview 'pacman -Si {}' | xargs -ro sudo pacman -S --needed"
}

_install_aur_pkg() {
    if [[ -z "${AUR_HELPER:-}" ]]; then _detect_aur_helper; fi
    if [[ -z "$AUR_HELPER" ]]; then
        notify-send -u critical "arch-boki" "No AUR helper found. Install yay or paru first."
        return 1
    fi
    present_terminal "${AUR_HELPER} -Slq | fzf --multi --preview '${AUR_HELPER} -Si {}' | xargs -ro ${AUR_HELPER} -S"
}

show_install_gtk_themes_menu() {
    case $(menu "GTK Themes" " Browse AUR themes\n Dracula\n Catppuccin\n Nordic\n Gruvbox\n Everforest") in
        *"Browse AUR"*) _install_aur_pkg ;;
        *Dracula*)      aur_install_pkg "Dracula GTK" "gtk-theme-dracula" ;;
        *Catppuccin*)   aur_install_pkg "Catppuccin GTK" "catppuccin-gtk-theme-mocha" ;;
        *Nordic*)       aur_install_pkg "Nordic GTK" "nordic-theme" ;;
        *Gruvbox*)      aur_install_pkg "Gruvbox GTK" "gruvbox-material-gtk-theme-git" ;;
        *Everforest*)   aur_install_pkg "Everforest GTK" "everforest-gtk-theme-git" ;;
        *)              return 1 ;;
    esac
}

show_install_icon_themes_menu() {
    case $(menu "Icon Themes" " Browse AUR icons\n Papirus\n Tela\n Numix\n Candy\n Reversal") in
        *"Browse AUR"*) _install_aur_pkg ;;
        *Papirus*)      install_pkg "Papirus Icons" "papirus-icon-theme" ;;
        *Tela*)         aur_install_pkg "Tela Icons" "tela-icon-theme" ;;
        *Numix*)        install_pkg "Numix Icons" "numix-icon-theme-git" ;;
        *Candy*)        aur_install_pkg "Candy Icons" "candy-icons-git" ;;
        *Reversal*)     aur_install_pkg "Reversal Icons" "reversal-icon-theme-git" ;;
        *)              return 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# REMOVE
# ---------------------------------------------------------------------------
show_remove_menu() {
    while true; do
        case $(menu "Remove" " System package\n Web App\n TUI") in
            *"System package"*) _remove_system_pkg; return 0 ;;
            *"Web App"*)        plain_terminal "${BOKI_CONFIG}/scripts/boki-webapp-remove"; return 0 ;;
            *TUI*)              plain_terminal "${BOKI_CONFIG}/scripts/boki-tui-remove"; return 0 ;;
            *)                  return 1 ;;
        esac
    done
}

_remove_system_pkg() {
    present_terminal "pacman -Qq | fzf --multi --preview 'pacman -Qi {}' | xargs -ro sudo pacman -Rns"
}

# ---------------------------------------------------------------------------
# UPDATE
# ---------------------------------------------------------------------------
show_update_menu() {
    while true; do
        case $(menu "Update" " AUR packages\n Full system update\n Keyboard layout\n Restart process\n Restart hardware\n Time sync\n Timezone") in
            *AUR*)          _update_aur; return 0 ;;
            *Full*)         present_terminal "yay -Syu || paru -Syu || sudo pacman -Syu"; return 0 ;;
            *Keyboard*)     show_keyboard_menu   || continue; return 0 ;;
            *"Restart process"*) show_restart_process_menu  || continue; return 0 ;;
            *"Restart hardware"*) show_restart_hardware_menu || continue; return 0 ;;
            *"Time sync"*)  present_terminal "sudo timedatectl set-ntp true && timedatectl status"; return 0 ;;
            *Timezone*)     present_terminal "tzselect && echo 'Run: sudo timedatectl set-timezone <zone>'"; return 0 ;;
            *)              return 1 ;;
        esac
    done
}

_update_aur() {
    if [[ -z "${AUR_HELPER:-}" ]]; then _detect_aur_helper; fi
    if [[ -z "$AUR_HELPER" ]]; then
        notify-send -u critical "arch-boki" "No AUR helper found."
        return 1
    fi
    present_terminal "${AUR_HELPER} -Sua"
}

show_keyboard_menu() {
    local keymap
    keymap=$(localectl list-keymaps | \
        rofi -no-config -dmenu -p "Keyboard layout" -width "$MENU_WIDTH" 2>/dev/null) || return 1
    [[ -z "$keymap" ]] && return 1
    present_terminal "sudo localectl set-keymap '${keymap}' && localectl status"
}

show_restart_process_menu() {
    case $(menu "Restart process" " Picom\n Fastcompmgr\n Sxhkd\n Dunst") in
        *Picom*)       _restart_picom ;;
        *Fastcompmgr*) _restart_fastcompmgr ;;
        *Sxhkd*)
            pkill sxhkd
            setsid sxhkd -c "${BOKI_CONFIG}/sxhkd/sxhkdrc" &>/dev/null &
            disown
            notify-send "arch-boki" "Sxhkd restarted" ;;
        *Dunst*)
            pkill dunst 2>/dev/null
            setsid dunst &>/dev/null &
            disown
            notify-send "arch-boki" "Dunst restarted" ;;
        *) return 1 ;;
    esac
}

show_restart_hardware_menu() {
    case $(menu "Restart hardware" " Audio (PipeWire)\n Audio (PulseAudio)\n WiFi\n Bluetooth") in
        *PipeWire*)   present_terminal "systemctl --user restart pipewire pipewire-pulse wireplumber && echo Done" ;;
        *PulseAudio*) present_terminal "systemctl --user restart pulseaudio && echo Done" ;;
        *WiFi*)       present_terminal "sudo systemctl restart NetworkManager && echo Done" ;;
        *Bluetooth*)  present_terminal "sudo systemctl restart bluetooth && echo Done" ;;
        *)            return 1 ;;
    esac
}

_restart_picom() {
    pkill fastcompmgr 2>/dev/null; pkill picom 2>/dev/null
    setsid picom --config "${BOKI_CONFIG}/picom/picom.conf" -b &>/dev/null &
    disown
    notify-send "arch-boki" "Picom restarted"
}

_restart_fastcompmgr() {
    pkill picom 2>/dev/null; pkill fastcompmgr 2>/dev/null
    setsid fastcompmgr -c &>/dev/null &
    disown
    notify-send "arch-boki" "Fastcompmgr restarted"
}

# ---------------------------------------------------------------------------
# POST INSTALL
# ---------------------------------------------------------------------------
show_post_install_menu() {
    case $(menu "Post Install" " Arch-Boki packages") in
        *"Arch-Boki"*) present_terminal "bash ${BOKI_CONFIG}/scripts/arch-boki-pkgs.sh" ;;
        *)             return 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# MAINTAIN CONFIGS
# ---------------------------------------------------------------------------
show_maintain_configs_menu() {
    while true; do
        case $(menu "Maintain Configs" " Shells\n Terminals\n Keybindings\n Chadwm-Boki\n Dunst\n Fastfetch\n Menu Launchers") in
            *Shells*)          show_maintain_shells_menu    || continue; return 0 ;;
            *Terminals*)       show_maintain_terminals_menu || continue; return 0 ;;
            *Keybindings*)     show_maintain_keybindings_menu || continue; return 0 ;;
            *"Chadwm-Boki"*)   open_in_thunar "${CHADWM_DIR}"; return 0 ;;
            *Dunst*)           edit_in_editor "${BOKI_HOME}/.config/dunst/dunstrc"; return 0 ;;
            *Fastfetch*)       edit_in_editor "${BOKI_HOME}/.config/fastfetch/config.jsonc"; return 0 ;;
            *"Menu Launchers"*) show_maintain_launchers_menu || continue; return 0 ;;
            *)                 return 1 ;;
        esac
    done
}

show_maintain_shells_menu() {
    case $(menu "Shells" " Bash config\n Bash aliases\n Fish config\n Starship config") in
        *"Bash config"*)   edit_in_editor "${BOKI_HOME}/.bashrc" ;;
        *"Bash aliases"*)  edit_in_editor "${BOKI_HOME}/.bash_aliases" ;;
        *"Fish config"*)   edit_in_editor "${BOKI_HOME}/.config/fish/config.fish" ;;
        *"Starship"*)      edit_in_editor "${BOKI_HOME}/.config/starship.toml" ;;
        *)                 return 1 ;;
    esac
}

show_maintain_terminals_menu() {
    case $(menu "Terminals" " Alacritty\n Kitty\n Ghostty\n WezTerm") in
        *Alacritty*) edit_in_editor "${BOKI_HOME}/.config/alacritty/alacritty.toml" ;;
        *Kitty*)     edit_in_editor "${BOKI_HOME}/.config/kitty/kitty.conf" ;;
        *Ghostty*)   edit_in_editor "${BOKI_HOME}/.config/ghostty/config" ;;
        *WezTerm*)   edit_in_editor "${BOKI_HOME}/.config/wezterm/wezterm.lua" ;;
        *)           return 1 ;;
    esac
}

show_maintain_keybindings_menu() {
    case $(menu "Keybindings" " Chadwm-Def-H\n Sxhkdrc") in
        *"Chadwm"*) edit_in_editor "${CHADWM_DIR}/config.def.h" ;;
        *Sxhkdrc*)  edit_in_editor "${BOKI_CONFIG}/sxhkd/sxhkdrc" ;;
        *)          return 1 ;;
    esac
}

show_maintain_launchers_menu() {
    local launchers_dir="${BOKI_CONFIG}/scripts/launchers"
    case $(menu "Menu Launchers" " Rofi config\n Chadwm-Boki config\n Config-Def-H\n DWM-C\n Rebuild-SH\n Run-SH\n Bar-SH\n EWW-Dock-Widget") in
        *"Rofi config"*)      edit_in_editor "${BOKI_HOME}/.config/rofi/config.rasi" ;;
        *"Chadwm-Boki"*)      open_in_thunar "${CHADWM_DIR}" ;;
        *"Config-Def-H"*)     edit_in_editor "${CHADWM_DIR}/config.def.h" ;;
        *"DWM-C"*)            edit_in_editor "${CHADWM_DIR}/dwm.c" ;;
        *"Rebuild-SH"*)       edit_in_editor "${CHADWM_DIR}/rebuild.sh" ;;
        *"Run-SH"*)           edit_in_editor "${BOKI_CONFIG}/scripts/run.sh" ;;
        *"Bar-SH"*)           edit_in_editor "${BOKI_CONFIG}/scripts/bar.sh" ;;
        *"EWW-Dock-Widget"*)  edit_in_editor "${BOKI_HOME}/.config/eww/dock.yuck" ;;
        *)                    return 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# SERVICES
# ---------------------------------------------------------------------------
show_services_menu() {
    case $(menu "Services" " Service restart 1\n Service restart 2\n Service restart 3") in
        *"Service restart 1"*) notify-send "arch-boki" "Service restart 1 — not yet configured" ;;
        *"Service restart 2"*) notify-send "arch-boki" "Service restart 2 — not yet configured" ;;
        *"Service restart 3"*) notify-send "arch-boki" "Service restart 3 — not yet configured" ;;
        *)                     return 1 ;;
    esac
}

# ===========================================================================
# INFO
# ===========================================================================
show_info_menu() {
    while true; do
        case $(menu "Info" " System Info - inxi\n OS Info - fastfetch\n System Monitor - btop\n GPU Monitor - nvtop\n Disk Overview\n Duf Details\n Disk Explorer") in
            *"System Info"*)    present_terminal "inxi -Fxxx"; return 0 ;;
            *"OS Info"*)        present_terminal "fastfetch"; return 0 ;;
            *"System Monitor"*)
                command -v btop &>/dev/null || install_pkg "btop" "btop"
                present_terminal "btop"; return 0 ;;
            *"GPU Monitor"*)
                command -v nvtop &>/dev/null || install_pkg "nvtop" "nvtop"
                present_terminal "nvtop"; return 0 ;;
            *"Disk Overview"*)  present_terminal "df -h | (read -r header; echo \"\$header\"; sort)"; return 0 ;;
            *"Duf Details"*)
                command -v duf &>/dev/null || install_pkg "duf" "duf"
                present_terminal "duf"; return 0 ;;
            *"Disk Explorer"*)
                command -v ncdu &>/dev/null || install_pkg "ncdu" "ncdu"
                present_terminal "ncdu ${BOKI_HOME}"; return 0 ;;
            *)                  return 1 ;;
        esac
    done
}

# ===========================================================================
# SYSTEM
# ===========================================================================
show_system_menu() {
    case $(menu "System" " Lock\n Logout\n Reboot\n Shutdown") in
        *Lock*)     _lock_screen ;;
        *Logout*)   _logout ;;
        *Reboot*)   systemctl reboot ;;
        *Shutdown*) systemctl poweroff ;;
        *)          return 1 ;;
    esac
}

_lock_screen() {
    if command -v betterlockscreen &>/dev/null; then
        betterlockscreen -l dim -- --time-str="%H:%M"
    elif command -v slock &>/dev/null; then
        slock
    else
        notify-send -u critical "arch-boki" "No screen locker found. Install slock or betterlockscreen."
    fi
}

_logout() {
    if command -v pkill &>/dev/null; then
        pkill -TERM -u "${BOKI_USER}"
    else
        notify-send -u critical "arch-boki" "Could not logout"
    fi
}

# ===========================================================================
# MAIN MENU
# ===========================================================================
show_main_menu() {
    while true; do
        case $(menu "Arch-Boki" " Apps\n Style\n Setup\n Trigger\n Learn\n Search\n Info\n System") in
            *Apps*)    local _launch_theme="$LAUNCHER_THEME"
                       if [[ -z "$_launch_theme" ]]; then
                           local _rasi_list _chosen_rasi
                           _rasi_list=$(find "${_SCRIPT_DIR}/menu" -name "*.rasi" 2>/dev/null | sort)
                           _chosen_rasi=$(echo "$_rasi_list" | \
                               rofi -dmenu -p "App launcher theme" -no-fixed-num-lines 2>/dev/null) || break
                           [[ -z "$_chosen_rasi" ]] && break
                           _launch_theme="$_chosen_rasi"
                       fi
                       rofi -no-config -no-lazy-grab -show Apps \
                           -modi "Apps,Accessories,Development,Graphics,Multimedia,Office,System,Settings,Internet" \
                           -i \
                           -theme "${_SCRIPT_DIR}/menu/ohmyarchboki-everforest-categories.rasi" 2>/dev/null
                       break ;;
            *Style*)   show_style_menu   || continue; break ;;
            *Setup*)   show_setup_menu   || continue; break ;;
            *Trigger*) show_trigger_menu || continue; break ;;
            *Learn*)   show_learn_menu   || continue; break ;;
            *Search*)  show_search_menu  || continue; break ;;
            *Info*)    show_info_menu    || continue; break ;;
            *System*)  show_system_menu  || continue; break ;;
            *)         break ;;
        esac
    done
}

# ===========================================================================
# ENTRY POINT
# ===========================================================================
[[ -f "$USER_EXTENSION" ]] && source "$USER_EXTENSION"

if [[ -n "${1:-}" ]]; then
    case "${1,,}" in
        *apps*)      _launch_theme="$LAUNCHER_THEME"
                     if [[ -z "$_launch_theme" ]]; then
                         _rasi_list=$(find "${_SCRIPT_DIR}/menu" -name "*.rasi" 2>/dev/null | sort)
                         _launch_theme=$(echo "$_rasi_list" | \
                             rofi -dmenu -p "App launcher theme" -no-fixed-num-lines 2>/dev/null) || true
                     fi
                     rofi -no-config -no-lazy-grab -show Apps \
                         -modi "Apps,Accessories,Development,Graphics,Multimedia,Office,System,Settings,Internet" \
                         -i \
                         -theme "${_SCRIPT_DIR}/menu/ohmyarchboki-everforest-categories.rasi" 2>/dev/null ;;
        *style*)     show_style_menu ;;
        *setup*)     show_setup_menu ;;
        *install*)   show_install_menu ;;
        *remove*)    show_remove_menu ;;
        *update*)    show_update_menu ;;
        *trigger*)   show_trigger_menu ;;
        *capture*)   show_capture_menu ;;
        *toggle*)    show_toggle_menu ;;
        *learn*)     show_learn_menu ;;
        *search*)    show_search_menu ;;
        *info*)      show_info_menu ;;
        *system*)    show_system_menu ;;
        *lock*)      _lock_screen ;;
        *configs*)   show_maintain_configs_menu ;;
        *services*)  show_services_menu ;;
        *)           show_main_menu ;;
    esac
else
    show_main_menu
fi
