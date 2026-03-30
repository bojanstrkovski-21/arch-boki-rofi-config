#!/bin/bash

ROFI_THEME="$HOME/.config/rofi/everforest-center.rasi"

install_pipewire() {
    if pacman -Qi jack2 &>/dev/null; then
        echo "Removing jack2..."
        sudo pacman -Rdd jack2
    fi
    sudo pacman -Rdd --noconfirm pulseaudio-bluetooth pulseaudio pulseaudio-alsa pulseaudio-equalizer pulseaudio-jack pulseaudio-zeroconf pavucontrol alsa-firmware alsa-lib alsa-plugins alsa-utils alsa-topology-conf gstreamer gst-plugins-good gst-plugins-bad gst-plugins-base gst-plugins-ugly gst-libav gstreamer-vaapi cdrdao faac faad2 ffmpeg ffmpegthumbnailer flac frei0r-plugins imagemagick lame libdvdcss libopenraw x265 x264 xvidcore playerctl volumeicon 2>/dev/null
    sudo pacman -Syu --noconfirm alsa-utils alsa-firmware alsa-plugins alsa-lib alsa-topology-conf gstreamer gst-libav gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly gstreamer-vaapi cdrdao faac faad2 ffmpeg ffmpegthumbnailer flac frei0r-plugins imagemagick lame libdvdcss libopenraw x265 x264 xvidcore pavucontrol pipewire pipewire-audio pipewire-docs pipewire-pulse pipewire-alsa pipewire-jack pipewire-zeroconf playerctl volumeicon wireplumber
}

install_pulseaudio() {
    if pacman -Qi jack2 &>/dev/null; then
        echo "Removing jack2..."
        sudo pacman -Rdd jack2
    fi
    sudo pacman -Rdd --noconfirm alsa-utils alsa-firmware alsa-plugins alsa-lib alsa-topology-conf gstreamer gst-libav gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly gstreamer-vaapi cdrdao faac faad2 ffmpeg ffmpegthumbnailer flac frei0r-plugins imagemagick lame libdvdcss libopenraw x265 x264 xvidcore pavucontrol pipewire pipewire-audio pipewire-docs pipewire-pulse pipewire-alsa pipewire-jack pipewire-zeroconf playerctl volumeicon wireplumber 2>/dev/null
    sudo pacman -Syu --noconfirm pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-equalizer pulseaudio-jack pulseaudio-zeroconf pavucontrol alsa-firmware alsa-lib alsa-plugins alsa-utils alsa-topology-conf gstreamer gst-plugins-good gst-plugins-bad gst-plugins-base gst-plugins-ugly gst-libav gstreamer-vaapi cdrdao faac faad2 ffmpeg ffmpegthumbnailer flac frei0r-plugins imagemagick lame libdvdcss libopenraw x265 x264 xvidcore playerctl volumeicon
}

show_audio_menu() {
    echo "󰝚 PipeWire"
    echo "󰓃 PulseAudio"
}

CHOICE=$(show_audio_menu | rofi -dmenu -i -p "Arch-Boki | Install Audio Drivers" -theme "$ROFI_THEME")
[[ $? -ne 0 || -z "$CHOICE" ]] && exit 0

case "$CHOICE" in
    *"PipeWire")   install_pipewire ;;
    *"PulseAudio") install_pulseaudio ;;
esac
