#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

ROFI_THEME="$HOME/.config/rofi/everforest-center.rasi"

# ── Main menu ─────────────────────────────────────────────────────────────────

show_main_menu() {
    echo "󰑓 Update and Refresh"
    echo "󰇄 Choose Desktop"
    echo "󰒓 Install Core Utils and Drivers"
    echo "󰀻 Install Apps"
    echo "󰐥 Quit"
}

# ── Update and Refresh submenu ────────────────────────────────────────────────

show_update_and_refresh() {
    echo "󰑓 Refresh Mirrors"
    echo "󰚰 Update System"
    echo " Add arch-boki Repos"
    echo " Add erik_dubois Repos"
    echo "󱓻 Add Chaotic Repos"
    echo "󰒓 Fix pacman DB and Keys"
    echo "󰏔 Install archlinux-tweak-tool"
}

# ── Choose Desktop submenu ────────────────────────────────────────────────────

show_choose_desktop() {
    echo "󰇄 KDE Plasma"
    echo " Xfce"
    echo " Cinnamon"
    echo "󰖙 Hyprland"
}

# ── Install Core Utils and Drivers submenu ────────────────────────────────────

show_install_core_utils() {
    echo "󰻠 CPU Microcode"
    echo "󰢮 GPU Drivers"
    echo "󰕾 Audio Drivers"
    echo "󰂯 Bluetooth Drivers"
    echo "󰤨 Network Drivers"
    echo "󰐪 Printer Drivers"
    echo "󰛖 Fonts"
    echo "󰒓 Core Utils"
}

# ── Actions ───────────────────────────────────────────────────────────────────

refresh_mirrors()        { ./add-repos/upd_servers.sh; }
update_system()          { sudo pacman -Syyu; }
add_archboki_repos()     { ./add-repos/append_archboki_repo.sh; }
add_arco_repos()         { ./add-repos/get-the-arcolinux-keys-and-repos.sh; }
add_chaotic_repos()      { ./add-repos/install_and_append_chaotic_repo_and_keyrings.sh; }
fix_pacman_db()          { ./add-repos/fix-pacman-databases-and-keys.sh; }
install_tweak_tool()     { sudo pacman -S archlinux-tweak-tool-git; }

install_kde()            { ./choose-desktop/kde-plasma/install-kde-plasma.sh; }
install_xfce()           { ./choose-desktop/xfce/install-xfce-and-sddm.sh; }
install_cinnamon()       { ./choose-desktop/cinnamon/install_cinnamon.sh; }
install_hyprland()       { ./choose-desktop/hyprland-scripts/00-hyprland-new.sh; }

install_microcode()      { ./core-utils/microcode.sh; }
install_gpu_drivers()    { ./core-utils/gpu-drivers.sh; }
install_audio_drivers()  { ./scripts-rofi/audio-drivers.sh; }
install_bluetooth()      { ./install-scripts/123-bluetooth.sh; }
install_network()        { ./install-scripts/126-network.sh; }
install_printers()       { ./install-scripts/124-printers.sh; }
install_fonts()          { ./scripts-rofi/install-fonts.sh; }
install_core_utils()     { ./install-scripts/118-core.sh; }

# ── Submenus ──────────────────────────────────────────────────────────────────

do_update_and_refresh() {
    CHOICE=$(show_update_and_refresh | rofi -dmenu -i -p "Arch-Boki | Update and Refresh" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$CHOICE" ]] && exit 0
    case "$CHOICE" in
        *"Refresh Mirrors")          refresh_mirrors ;;
        *"Update System")            update_system ;;
        *"Add arch-boki Repos")      add_archboki_repos ;;
        *"Add erik_dubois Repos")    add_arco_repos ;;
        *"Add Chaotic Repos")        add_chaotic_repos ;;
        *"Fix pacman DB and Keys")   fix_pacman_db ;;
        *"archlinux-tweak-tool")     install_tweak_tool ;;
    esac
}

do_choose_desktop() {
    CHOICE=$(show_choose_desktop | rofi -dmenu -i -p "Arch-Boki | Choose Desktop" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$CHOICE" ]] && exit 0
    case "$CHOICE" in
        *"KDE Plasma")  install_kde ;;
        *"Xfce")        install_xfce ;;
        *"Cinnamon")    install_cinnamon ;;
        *"Hyprland")    install_hyprland ;;
    esac
}

do_install_core_utils() {
    CHOICE=$(show_install_core_utils | rofi -dmenu -i -p "Arch-Boki | Core Utils and Drivers" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$CHOICE" ]] && exit 0
    case "$CHOICE" in
        *"CPU Microcode")    install_microcode ;;
        *"GPU Drivers")      install_gpu_drivers ;;
        *"Audio Drivers")    install_audio_drivers ;;
        *"Bluetooth")        install_bluetooth ;;
        *"Network")          install_network ;;
        *"Printer")          install_printers ;;
        *"Fonts")            install_fonts ;;
        *"Core Utils")       install_core_utils ;;
    esac
}

# ── Main logic ────────────────────────────────────────────────────────────────

CHOICE=$(show_main_menu | rofi -dmenu -i -p "Arch-Boki" -theme "$ROFI_THEME")
[[ $? -ne 0 || -z "$CHOICE" ]] && exit 0

case "$CHOICE" in
    *"Update and Refresh")          do_update_and_refresh ;;
    *"Choose Desktop")              do_choose_desktop ;;
    *"Install Core Utils")          do_install_core_utils ;;
    *"Install Apps")                exec ./scripts-rofi/install-apps.sh ;;
    *"Quit")                        exit 0 ;;
esac

