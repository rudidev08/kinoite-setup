#!/bin/bash

# Cache sudo credentials
sudo -v

# Step counter for progress display
CURRENT_STEP=0
TOTAL_STEPS=15

step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo ""
    echo "[$CURRENT_STEP/$TOTAL_STEPS] $1"
}

# Combined step counter with yes/no confirmation
step_confirm() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    while true; do
        read -p "[$CURRENT_STEP/$TOTAL_STEPS] $1 [Y/n]: " yn < /dev/tty
        yn=${yn:-y}
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# confirms with user if to run a function or not
# default to yes if empty
confirm_yes_no() {
    while true; do
        # /dev/tty is needed if ran via curl
        read -p "$1 [Y/n]: "  yn < /dev/tty
        yn=${yn:-y}
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# rpm-ostree package layering
# PACKAGES and hooks are embedded by build.sh

setup_2_300_rpm_ostree() {
    local all_packages="1password 1password-cli code deskflow distrobox fish lutris mangohud liberation-fonts steam"
    local selected=""
    local install_ffmpeg=""

    # Package selection
    for pkg in $all_packages; do
        if step_confirm "layer $pkg?"; then
            selected="$selected $pkg"
        fi
    done

    # GPU drivers (from RPM Fusion)
    step "GPU drivers"
    while true; do
        read -p "video acceleration driver? [a]md / [i]ntel / [n]one: " gpu_choice < /dev/tty
        case $gpu_choice in
            [Aa]* )
                selected="$selected mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld"
                break;;
            [Ii]* )
                selected="$selected intel-media-driver"
                break;;
            [Nn]* )
                break;;
            * )
                echo "Please enter a, i, or n";;
        esac
    done

    # ffmpeg (from RPM Fusion)
    step "codecs"
    if confirm_yes_no "replace ffmpeg-free with ffmpeg (full codec support)?"; then
        install_ffmpeg="yes"
    fi

    selected=$(echo "$selected" | xargs)

    # run package hooks
    if [[ "$selected" == *"1password"* ]]; then
cat << 'EOF' | sudo tee /etc/yum.repos.d/1password.repo > /dev/null
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF
    fi
    if [[ "$selected" == *"code"* ]]; then
cat << 'EOF' | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
    fi

    # refresh repo metadata after hooks add repos
    rpm-ostree refresh-md

    # Execute rpm-ostree operations
    if [ -n "$selected" ]; then
        echo ""
        echo "Layering packages"
        rpm-ostree install $selected
    fi

    if [ -n "$install_ffmpeg" ]; then
        echo ""
        echo "Replacing ffmpeg-free with ffmpeg"
        rpm-ostree override remove ffmpeg-free libavcodec-free libavdevice-free libavfilter-free libavformat-free libavutil-free libpostproc-free libswresample-free libswscale-free --install ffmpeg
    fi

    if [ -z "$selected" ] && [ -z "$install_ffmpeg" ]; then
        echo ""
        echo "No packages selected"
    fi
}

# flatpak installs from flathub
# FLATPAKS content is embedded by build.sh

setup_2_400_flatpak() {
    local all_flatpaks="com.borgbase.Vorta com.fastmail.Fastmail com.github.tchx84.Flatseal io.github.flattool.Warehouse io.github.kolunmi.Bazaar io.missioncenter.MissionCenter it.mijorus.gearlever org.fedoraproject.MediaWriter org.gnome.Weather org.kde.haruna org.kde.kate org.kde.krita org.videolan.VLC"
    local selected=""
    local to_remove=""

    step "flatpaks"

    # Remove pre-installed flatpaks
    echo "-- remove --"
    if confirm_yes_no "remove KDE games (kmahjongg, kmines)?"; then
        to_remove="org.kde.kmahjongg org.kde.kmines"
    fi

    if [ -n "$to_remove" ]; then
        echo "Removing: $to_remove"
        flatpak uninstall -y --noninteractive $to_remove
    fi

    # Install flatpaks
    echo ""
    echo "-- install --"
    local total=$(echo $all_flatpaks | wc -w)
    local i=0
    for app in $all_flatpaks; do
        i=$((i + 1))
        if confirm_yes_no "($i/$total) install $app?"; then
            selected="$selected $app"
        fi
    done

    selected=$(echo "$selected" | xargs)

    if [ -z "$selected" ]; then
        echo "No flatpaks selected"
        return
    fi

    echo "Installing: $selected"
    flatpak install -y --noninteractive flathub $selected
}

# Aurora wallpapers from ublue-os/artwork

setup_2_410_wallpapers() {
    step "wallpapers"
    if confirm_yes_no "install Aurora wallpapers?"; then
        local dest="$HOME/.local/share/wallpapers"
        mkdir -p "$dest"

        echo "Downloading Aurora wallpapers..."
        local tmpdir=$(mktemp -d)
        curl -sL https://github.com/ublue-os/artwork/archive/refs/heads/main.tar.gz | tar -xz -C "$tmpdir"
        cp -r "$tmpdir/artwork-main/wallpapers/aurora/"* "$dest/"
        rm -rf "$tmpdir"

        echo "Wallpapers installed to $dest"
    fi
}

# Fontconfig: substitute Liberation fonts for MS fonts

setup_2_420_fontconfig() {
    step "fontconfig"
    if confirm_yes_no "configure Liberation fonts as MS font substitutes?"; then
        local config_dir="$HOME/.config/fontconfig"
        mkdir -p "$config_dir"

        cat > "$config_dir/fonts.conf" << 'FONTCONF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <!-- Substitute Liberation fonts for MS fonts -->
  <alias>
    <family>Arial</family>
    <prefer><family>Liberation Sans</family></prefer>
  </alias>
  <alias>
    <family>Helvetica</family>
    <prefer><family>Liberation Sans</family></prefer>
  </alias>
  <alias>
    <family>Times New Roman</family>
    <prefer><family>Liberation Serif</family></prefer>
  </alias>
  <alias>
    <family>Times</family>
    <prefer><family>Liberation Serif</family></prefer>
  </alias>
  <alias>
    <family>Courier New</family>
    <prefer><family>Liberation Mono</family></prefer>
  </alias>
</fontconfig>
FONTCONF

        echo "Fontconfig updated: $config_dir/fonts.conf"
        fc-cache -f
    fi
}


# run all functions starting with "setup_2"
for func in $(declare -F | awk '{print $3}' | grep "^setup_2" | sort); do
    $func
done

stty sane 2>/dev/null
echo ""
echo "Done! AppImages to download:"
echo ""
cat << 'APPIMAGES_EOF'
Helium Browser: https://helium.foundation/download
Obsidian: https://obsidian.md/download
pCloud: https://www.pcloud.com/download-free-online-cloud-file-storage.html
Todoist: https://todoist.com/downloads
APPIMAGES_EOF
