#!/bin/bash
# install-apps.sh — Rofi-based app installer (rewrite of 130-archboki-install-apps.sh)

ROFI_THEME="$HOME/.config/rofi/everforest-center.rasi"

# ── helpers ──────────────────────────────────────────────────────────────────

inst() {
    sudo pacman -S --needed --noconfirm "$@"
}

# ── install actions ───────────────────────────────────────────────────────────

nemo_file_manager()    { inst nemo nemo-compare nemo-fileroller nemo-image-converter nemo-preview nemo-share; }
pcmanfm_gtk3()         { inst pcmanfm-gtk3; }
pcmanfm_qt()           { inst pcmanfm-qt; }
thunar_file_manager()  { inst thunar thunar-archive-plugin thunar-shares-plugin thunar-volman tumbler file-roller; }
nautilus_gnome()       { inst nautilus nautilus-share sushi nautilus-code-git nautilus-open-any-terminal; }
dolphin()              { inst dolphin dolphin-plugins; }
yazi_terminal()        { inst yazi; }
ranger_terminal()      { inst ranger; }

alacritty()            { inst alacritty alacritty-themes imagemagick libsixel lsix; }
ghostty()              { inst ghostty libsixel imagemagick lsix; }
kitty()                { inst kitty kitty-shell-integration libsixel lsix imagemagick; }
tilix()                { inst tilix; }
wezterm()              { inst wezterm-nightly-bin imagemagick; }
xfce4_terminal()       { inst xfce4-terminal; }

emacs()                { inst emacs; }
geany()                { inst geany geany-plugins; }
leafpad()              { inst leafpad; }
mousepad()             { inst mousepad; }
sublime_text()         { inst sublime-text-4; }
xed()                  { inst xed; }

libreoffice()          { inst libreoffice-fresh; }
onlyoffice()           { inst onlyoffice; }

obsidian()             { inst obsidian; }
qownnotes()            { inst qownnotes; }

evince()               { inst evince; }
okular()               { inst okular; }
xpdf()                 { inst xpdf; }
xreader()              { inst xreader; }
zathura()              { inst zathura; }

code_editor()          { inst code; }
meld()                 { inst meld; }
notepadqq()            { inst notepadqq; }
pycharm()              { inst pycharm-community-edition; }
vscodium()             { inst vscodium vscodium-marketplace; }
vscode()               { inst visual-studio-code-bin; }
zed()                  { inst zed; }

discord()              { inst discord; }
signal()               { inst signal-desktop; }
telegram()             { inst telegram-desktop; }

brave()                { inst brave-bin; }
chromium()             { inst chromium; }
firefox()              { inst firefox; }
firefox_esr()          { inst firefox-esr; }
google_chrome()        { inst google-chrome; }
librewolf()            { inst librewolf; }
qutebrowser()          { inst qutebrowser; }
vivaldi()              { inst vivaldi vivaldi-ffmpeg-codecs; }

deluge()               { inst deluge-gtk; }
ktorrent()             { inst ktorrent; }
qbittorrent()          { inst qbittorrent; }
transmission_gtk()     { inst transmission-gtk; }
transmission_qt()      { inst transmission-qt; }

gpu_screen_recorder()  { inst gpu-screen-recorder gpu-screen-recorder-gtk; }
hyprshot()             { inst hyprshot; }
kazam()                { inst kazam; }
obs_studio()           { inst obs-studio; }
peek()                 { inst peek; }
simplescreenrecorder() { inst simplescreenrecorder-qt6-git; }

amberol()              { inst amberol; }
audacious()            { inst audacious audacious-plugins; }
deadbeef()             { inst deadbeef; }
elisa()                { inst elisa; }
g4music()              { inst g4music-git; }
juk()                  { inst juk; }
lollypop()             { inst lollypop; }
pragha()               { inst pragha; }
rhythmbox()            { inst rhythmbox; }
sayonara()             { inst sayonara-player; }
strawberry()           { inst strawberry; }

celluloid()            { inst celluloid; }
clapper()              { inst clapper clapper-enhancers; }
kodi()                 { inst kodi; }
mpv()                  { inst mpv; }
smplayer()             { inst smplayer smplayer-skins smplayer-themes; }
vlc()                  { inst vlc; }

ardour()               { inst ardour; }
audacity()             { inst audacity; }
kwave()                { inst kwave; }
lmms()                 { inst lmms; }
openshot()             { inst openshot; }
soundconverter()       { inst soundconverter; }
reaper()               { inst reaper reapack sws; }
tenacity()             { inst tenacity; }

flowblade()            { inst flowblade; }
handbrake()            { inst handbrake; }
kdenlive()             { inst kdenlive; }
losslesscut()          { inst losslesscut-bin; }
makemkv()              { inst makemkv mkvtoolnix-cli mkvtoolnix-gui; }
shotcut()              { inst shotcut; }

aegisub()              { inst aegisub; }
subtitleedit()         { inst subtitleedit; }
subtitlecomposer()     { inst subtitlecomposer; }

darktable()            { inst darktable; }
ephoto()               { inst ephoto; }
gpicview()             { inst gpicview; }
gwenview()             { inst gwenview; }
nomacs()               { inst nomacs; }
nsxiv()                { inst nsxiv; }
qimgv()                { inst qimgv-git; }
ristretto()            { inst ristretto; }

gimp()                 { inst gimp; }
gpick()                { inst gpick; }
inkscape()             { inst inkscape; }
krita()                { inst krita; }
pinta()                { inst pinta; }
rawtherapee()          { inst rawtherapee; }
upscayl()              { inst upscayl-desktop-git upscayl-models-desktop; }

azote()                { inst azote; }
feh()                  { inst feh; }
hyprpaper()            { inst hyprpaper; }
nitrogen()             { inst nitrogen; }
swaybg()               { inst swaybg; }
swww()                 { inst swww; }
variety()              { inst variety; }
waypaper()             { inst waypaper-git; }
xwallpaper()           { inst xwallpaper; }

bashtop()              { inst bashtop; }
btop()                 { inst btop; }
countryfetch()         { inst countryfetch; }
cpufetch()             { inst cpufetch; }
fastfetch()            { inst fastfetch; }
glances()              { inst glances; }
gtop()                 { inst gtop; }
htop()                 { inst htop; }
hyfetch()              { inst hyfetch; }
mission_center()       { inst mission-center; }
nvtop()                { inst nvtop; }
resources()            { inst resources; }
xfce4_taskmanager()    { inst xfce4-taskmanager; }

bemenu()               { inst bemenu; }
bemenu_wayland()       { inst bemenu-wayland; }
dmenu()                { inst dmenu; }
fuzzel()               { inst fuzzel; }
rofi_x11()             { inst rofi; }
rofi_wayland()         { inst rofi-wayland; }
tofi()                 { inst tofi; }
walker()               { inst walker-bin; }
wofi()                 { inst wofi; }

galculator()           { inst galculator; }
gnome_calculator()     { inst gnome-calculator; }
qalculate_gtk()        { inst qalculate-gtk; }
qalculate_qt()         { inst qalculate-qt; }

partitionmanager()     { inst partitionmanager; }
gnome_disks()          { inst gnome-disk-utility; }
gparted()              { inst gparted; }

flameshot()            { inst flameshot; }
ksnip()                { inst ksnip; }
shutter()              { inst shutter; }
spectacle()            { inst spectacle; }
xfce4_screenshooter()  { inst xfce4-screenshooter; }

arandr()               { inst arandr; }
nwg_displays()         { inst nwg-displays; }
wdisplays()            { inst wdisplays; }
wlr_randr()            { inst wlr-randr; }
xrandr()               { inst xorg-xrandr; }

# ── menus ────────────────────────────────────────────────────────────────────

show_file_managers() {
    C=$(echo -e "Nemo\nPcmanFM-gtk3\nPcmanFM-qt\nThunar\nNautilus (Gnome)\nDolphin (KDE)\nYazi (Terminal)\nRanger (Terminal)" \
        | rofi -dmenu -i -p "Arch-Boki | File Managers" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Nemo")            nemo_file_manager ;;
        *"PcmanFM-gtk3")    pcmanfm_gtk3 ;;
        *"PcmanFM-qt")      pcmanfm_qt ;;
        *"Thunar")          thunar_file_manager ;;
        *"Nautilus")        nautilus_gnome ;;
        *"Dolphin")         dolphin ;;
        *"Yazi")            yazi_terminal ;;
        *"Ranger")          ranger_terminal ;;
    esac
}

show_terminal_emulators() {
    C=$(echo -e "Alacritty\nGhostty\nKitty\nTilix\nWezterm\nXfce4-Terminal" \
        | rofi -dmenu -i -p "Arch-Boki | Terminal Emulators" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Alacritty")      alacritty ;;
        *"Ghostty")        ghostty ;;
        *"Kitty")          kitty ;;
        *"Tilix")          tilix ;;
        *"Wezterm")        wezterm ;;
        *"Xfce4-Terminal") xfce4_terminal ;;
    esac
}

show_text_editors() {
    C=$(echo -e "Emacs\nGeany\nLeafpad (Lxde)\nMousepad (Xfce)\nSublime-Text-4\nXed (Linux Mint)" \
        | rofi -dmenu -i -p "Arch-Boki | Text Editors" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Emacs")    emacs ;;
        *"Geany")    geany ;;
        *"Leafpad")  leafpad ;;
        *"Mousepad") mousepad ;;
        *"Sublime")  sublime_text ;;
        *"Xed")      xed ;;
    esac
}

show_office_suites() {
    C=$(echo -e "LibreOffice\nOnlyOffice" \
        | rofi -dmenu -i -p "Arch-Boki | Office Suites" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"LibreOffice") libreoffice ;;
        *"OnlyOffice")  onlyoffice ;;
    esac
}

show_markdown_editors() {
    C=$(echo -e "Affine\nObsidian\nQownNotes" \
        | rofi -dmenu -i -p "Arch-Boki | Markdown Editors" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Affine")    affine ;;
        *"Obsidian")  obsidian ;;
        *"QownNotes") qownnotes ;;
    esac
}

show_pdf_viewers() {
    C=$(echo -e "Evince\nOkular\nXpdf\nXreader\nZathura" \
        | rofi -dmenu -i -p "Arch-Boki | PDF Viewers" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Evince")  evince ;;
        *"Okular")  okular ;;
        *"Xpdf")    xpdf ;;
        *"Xreader") xreader ;;
        *"Zathura") zathura ;;
    esac
}

show_devtools() {
    C=$(echo -e "Code\nMeld\nNotepadqq\nPycharm Community\nVSCodium\nVisual Studio Code\nZed" \
        | rofi -dmenu -i -p "Arch-Boki | Dev Tools" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Code")               code_editor ;;
        *"Meld")               meld ;;
        *"Notepadqq")          notepadqq ;;
        *"Pycharm")            pycharm ;;
        *"VSCodium")           vscodium ;;
        *"Visual Studio Code") vscode ;;
        *"Zed")                zed ;;
    esac
}

show_text_devt_office_pdf() {
    C=$(echo -e "Text Editors\nOffice Suites\nMarkdown Editors\nPDF Viewers\nDev Tools" \
        | rofi -dmenu -i -p "Arch-Boki | Text, PDF, Dev Tools" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Text Editors")     show_text_editors ;;
        *"Office Suites")    show_office_suites ;;
        *"Markdown Editors") show_markdown_editors ;;
        *"PDF Viewers")      show_pdf_viewers ;;
        *"Dev Tools")        show_devtools ;;
    esac
}

show_communication() {
    C=$(echo -e "Discord\nSignal\nTelegram" \
        | rofi -dmenu -i -p "Arch-Boki | Communication / Social" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Discord")  discord ;;
        *"Signal")   signal ;;
        *"Telegram") telegram ;;
    esac
}

show_web_browsers() {
    C=$(echo -e "Brave\nChromium\nFirefox ESR\nFirefox\nGoogle Chrome\nLibrewolf\nQutebrowser\nVivaldi" \
        | rofi -dmenu -i -p "Arch-Boki | Web Browsers" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Brave")         brave ;;
        *"Chromium")      chromium ;;
        *"Firefox ESR")   firefox_esr ;;
        *"Firefox")       firefox ;;
        *"Google Chrome") google_chrome ;;
        *"Librewolf")     librewolf ;;
        *"Qutebrowser")   qutebrowser ;;
        *"Vivaldi")       vivaldi ;;
    esac
}

show_downloaders() {
    C=$(echo -e "Deluge-Gtk\nKtorrent\nQbittorrent\nTransmission-Gtk\nTransmission-Qt" \
        | rofi -dmenu -i -p "Arch-Boki | Downloaders" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Deluge-Gtk")       deluge ;;
        *"Ktorrent")         ktorrent ;;
        *"Qbittorrent")      qbittorrent ;;
        *"Transmission-Gtk") transmission_gtk ;;
        *"Transmission-Qt")  transmission_qt ;;
    esac
}

show_recorders() {
    C=$(echo -e "GPU Screen Recorder\nHyprshot (Hyprland only)\nKazam\nOBS Studio\nPeek\nSimpleScreenRecorder" \
        | rofi -dmenu -i -p "Arch-Boki | Recorders" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"GPU Screen Recorder")  gpu_screen_recorder ;;
        *"Hyprshot")             hyprshot ;;
        *"Kazam")                kazam ;;
        *"OBS Studio")           obs_studio ;;
        *"Peek")                 peek ;;
        *"SimpleScreenRecorder") simplescreenrecorder ;;
    esac
}

show_internet() {
    C=$(echo -e "Communication / Social\nWeb Browsers\nDownloaders\nRecorders" \
        | rofi -dmenu -i -p "Arch-Boki | Internet" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Communication") show_communication ;;
        *"Web Browsers")  show_web_browsers ;;
        *"Downloaders")   show_downloaders ;;
        *"Recorders")     show_recorders ;;
    esac
}

show_audio_players() {
    C=$(echo -e "Amberol\nAudacious\nDeadbeef\nElisa\nG4music\nJuk\nLollypop\nPragha\nRhythmbox\nSayonara Player\nStrawberry" \
        | rofi -dmenu -i -p "Arch-Boki | Audio Players" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Amberol")         amberol ;;
        *"Audacious")       audacious ;;
        *"Deadbeef")        deadbeef ;;
        *"Elisa")           elisa ;;
        *"G4music")         g4music ;;
        *"Juk")             juk ;;
        *"Lollypop")        lollypop ;;
        *"Pragha")          pragha ;;
        *"Rhythmbox")       rhythmbox ;;
        *"Sayonara Player") sayonara ;;
        *"Strawberry")      strawberry ;;
    esac
}

show_video_players() {
    C=$(echo -e "Celluloid\nClapper\nKodi\nMpv\nSmplayer\nVLC" \
        | rofi -dmenu -i -p "Arch-Boki | Video Players" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Celluloid") celluloid ;;
        *"Clapper")   clapper ;;
        *"Kodi")      kodi ;;
        *"Mpv")       mpv ;;
        *"Smplayer")  smplayer ;;
        *"VLC")       vlc ;;
    esac
}

show_audio_editors() {
    C=$(echo -e "Ardour\nAudacity\nKwave\nLMMS\nOpenshot\nSoundConverter\nReaper\nTenacity" \
        | rofi -dmenu -i -p "Arch-Boki | Audio Editors" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Ardour")         ardour ;;
        *"Audacity")       audacity ;;
        *"Kwave")          kwave ;;
        *"LMMS")           lmms ;;
        *"Openshot")       openshot ;;
        *"SoundConverter") soundconverter ;;
        *"Reaper")         reaper ;;
        *"Tenacity")       tenacity ;;
    esac
}

show_video_editors() {
    C=$(echo -e "Flowblade\nHandbrake\nKdenlive\nLosslessCut\nMakeMKV\nOpenshot\nShotcut" \
        | rofi -dmenu -i -p "Arch-Boki | Video Editors" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Flowblade")   flowblade ;;
        *"Handbrake")   handbrake ;;
        *"Kdenlive")    kdenlive ;;
        *"LosslessCut") losslesscut ;;
        *"MakeMKV")     makemkv ;;
        *"Openshot")    openshot ;;
        *"Shotcut")     shotcut ;;
    esac
}

show_subtitle_editors() {
    C=$(echo -e "Aegisub\nSubtitleEdit\nSubtitleComposer" \
        | rofi -dmenu -i -p "Arch-Boki | Subtitle Editors" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Aegisub")           aegisub ;;
        *"SubtitleEdit")      subtitleedit ;;
        *"SubtitleComposer")  subtitlecomposer ;;
    esac
}

show_multimedia() {
    C=$(echo -e "Audio Players\nVideo Players\nAudio Editors\nVideo Editors\nSubtitle Editors" \
        | rofi -dmenu -i -p "Arch-Boki | Multimedia" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Audio Players")    show_audio_players ;;
        *"Video Players")    show_video_players ;;
        *"Audio Editors")    show_audio_editors ;;
        *"Video Editors")    show_video_editors ;;
        *"Subtitle Editors") show_subtitle_editors ;;
    esac
}

show_photo_viewers() {
    C=$(echo -e "Darktable\nEphoto\nGPicView\nGwenview\nNomacs\nNsxiv\nQimgv\nRistretto" \
        | rofi -dmenu -i -p "Arch-Boki | Photo / Image Viewers" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Darktable") darktable ;;
        *"Ephoto")    ephoto ;;
        *"GPicView")  gpicview ;;
        *"Gwenview")  gwenview ;;
        *"Nomacs")    nomacs ;;
        *"Nsxiv")     nsxiv ;;
        *"Qimgv")     qimgv ;;
        *"Ristretto") ristretto ;;
    esac
}

show_photo_editors() {
    C=$(echo -e "Gimp\nGpick\nInkscape\nKrita\nPinta\nRawTherapee\nUpscayl" \
        | rofi -dmenu -i -p "Arch-Boki | Photo / Image Editors" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Gimp")        gimp ;;
        *"Gpick")       gpick ;;
        *"Inkscape")    inkscape ;;
        *"Krita")       krita ;;
        *"Pinta")       pinta ;;
        *"RawTherapee") rawtherapee ;;
        *"Upscayl")     upscayl ;;
    esac
}

show_wallpaper_changer() {
    C=$(echo -e "Azote (nwg)\nFeh (terminal)\nHyprpaper (Hyprland)\nNitrogen\nSwaybg (terminal wayland)\nSwww (terminal)\nVariety\nWaypaper (wayland/x11 gui)\nXwallpaper (terminal)" \
        | rofi -dmenu -i -p "Arch-Boki | Wallpaper Changer" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Azote")      azote ;;
        *"Feh")        feh ;;
        *"Hyprpaper")  hyprpaper ;;
        *"Nitrogen")   nitrogen ;;
        *"Swaybg")     swaybg ;;
        *"Swww")       swww ;;
        *"Variety")    variety ;;
        *"Waypaper")   waypaper ;;
        *"Xwallpaper") xwallpaper ;;
    esac
}

show_graphics() {
    C=$(echo -e "Photo / Image Viewers\nPhoto / Image Editors\nWallpaper / Background Changer" \
        | rofi -dmenu -i -p "Arch-Boki | Graphics" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Photo / Image Viewers")          show_photo_viewers ;;
        *"Photo / Image Editors")          show_photo_editors ;;
        *"Wallpaper / Background Changer") show_wallpaper_changer ;;
    esac
}

show_system_info() {
    C=$(echo -e "Bashtop\nBtop\nCountryfetch\nCpufetch\nFastfetch\nGlances\nGtop\nHtop\nHyfetch\nMission Center\nNvtop\nResources\nStacer\nXfce4-Taskmanager" \
        | rofi -dmenu -i -p "Arch-Boki | System Info / Monitoring" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Bashtop")           bashtop ;;
        *"Btop")              btop ;;
        *"Countryfetch")      countryfetch ;;
        *"Cpufetch")          cpufetch ;;
        *"Fastfetch")         fastfetch ;;
        *"Glances")           glances ;;
        *"Gtop")              gtop ;;
        *"Htop")              htop ;;
        *"Hyfetch")           hyfetch ;;
        *"Mission Center")    mission_center ;;
        *"Nvtop")             nvtop ;;
        *"Resources")         resources ;;
        *"Stacer")            stacer ;;
        *"Xfce4-Taskmanager") xfce4_taskmanager ;;
    esac
}

show_app_launchers() {
    C=$(echo -e "Bemenu\nBemenu-Wayland\nDmenu\nFuzzel\nRofi\nRofi-Wayland\nTofi\nWalker\nWofi" \
        | rofi -dmenu -i -p "Arch-Boki | App Launchers" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Bemenu-Wayland") bemenu_wayland ;;
        *"Bemenu")         bemenu ;;
        *"Dmenu")          dmenu ;;
        *"Fuzzel")         fuzzel ;;
        *"Rofi-Wayland")   rofi_wayland ;;
        *"Rofi")           rofi_x11 ;;
        *"Tofi")           tofi ;;
        *"Walker")         walker ;;
        *"Wofi")           wofi ;;
    esac
}

show_calculators() {
    C=$(echo -e "Galculator\nGnome Calculator\nQalculate-Gtk\nQalculate-Qt" \
        | rofi -dmenu -i -p "Arch-Boki | Calculators" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Galculator")       galculator ;;
        *"Gnome Calculator") gnome_calculator ;;
        *"Qalculate-Gtk")    qalculate_gtk ;;
        *"Qalculate-Qt")     qalculate_qt ;;
    esac
}

show_partition_tools() {
    C=$(echo -e "KDE Partition Manager\nGnome Disks Utility\nGparted" \
        | rofi -dmenu -i -p "Arch-Boki | Partition Tools" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"KDE Partition Manager") partitionmanager ;;
        *"Gnome Disks Utility")   gnome_disks ;;
        *"Gparted")               gparted ;;
    esac
}

show_screen_shooters() {
    C=$(echo -e "Flameshot\nKazam\nKsnip\nShutter\nSpectacle\nXfce4-Screenshooter" \
        | rofi -dmenu -i -p "Arch-Boki | Screen Shooters" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Flameshot")           flameshot ;;
        *"Kazam")               kazam ;;
        *"Ksnip")               ksnip ;;
        *"Shutter")             shutter ;;
        *"Spectacle")           spectacle ;;
        *"Xfce4-Screenshooter") xfce4_screenshooter ;;
    esac
}

show_screen_resolution() {
    C=$(echo -e "Arandr (gui x11)\nNwg-displays (Hyprland/Sway)\nWdisplays (gui wayland)\nWlr-randr (cli wayland)\nXrandr (cli x11)" \
        | rofi -dmenu -i -p "Arch-Boki | Screen Resolution" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"Arandr")       arandr ;;
        *"Nwg-displays") nwg_displays ;;
        *"Wdisplays")    wdisplays ;;
        *"Wlr-randr")    wlr_randr ;;
        *"Xrandr")       xrandr ;;
    esac
}

show_system_tools() {
    C=$(echo -e "App Launchers\nCalculators\nPartition Tools\nScreen Shooters\nScreen Resolution Setters" \
        | rofi -dmenu -i -p "Arch-Boki | System Tools" -theme "$ROFI_THEME")
    [[ $? -ne 0 || -z "$C" ]] && exit 0
    case "$C" in
        *"App Launchers")             show_app_launchers ;;
        *"Calculators")               show_calculators ;;
        *"Partition Tools")           show_partition_tools ;;
        *"Screen Shooters")           show_screen_shooters ;;
        *"Screen Resolution Setters") show_screen_resolution ;;
    esac
}

# ── main logic ────────────────────────────────────────────────────────────────

CHOICE=$(echo -e "File Managers\nTerminal Emulators\nText, PDF, Dev Tools\nInternet\nMultimedia\nGraphics\nSystem Info / Monitoring\nSystem Tools\nQuit" \
    | rofi -dmenu -i -p "Arch-Boki | Install Apps" -theme "$ROFI_THEME")
[[ $? -ne 0 || -z "$CHOICE" ]] && exit 0

case "$CHOICE" in
    *"File Managers")            show_file_managers ;;
    *"Terminal Emulators")       show_terminal_emulators ;;
    *"Text, PDF, Dev Tools")     show_text_devt_office_pdf ;;
    *"Internet")                 show_internet ;;
    *"Multimedia")               show_multimedia ;;
    *"Graphics")                 show_graphics ;;
    *"System Info / Monitoring") show_system_info ;;
    *"System Tools")             show_system_tools ;;
    *"Quit")                     exit 0 ;;
esac

