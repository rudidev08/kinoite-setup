#!/bin/bash

# Cache sudo credentials
sudo -v

# Step counter for progress display
CURRENT_STEP=0
TOTAL_STEPS=10

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

# hostname setup

setup_1_100_hostname() {
    echo ""
    echo "[1/3] | hostname"
    echo ""
    read -p "New hostname (current: $(hostnamectl hostname)): " new_hostname < /dev/tty

    if [ -n "$new_hostname" ]; then
        hostnamectl hostname "$new_hostname"
        echo "Hostname set to: $new_hostname"
    fi
}

# flatpak repos setup

setup_1_200_flatpak_repos() {
    echo ""
    echo "[2/3] | flatpak repos"
    echo ""

    if confirm_yes_no "disable fedora flatpak and enable flathub?"; then
        flatpak remote-modify --disable fedora
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        flatpak remote-modify --enable flathub
    fi
}

# RPM Fusion repos setup

setup_1_205_rpmfusion() {
    echo ""
    echo "[3/3] | RPM Fusion"
    echo ""

    if confirm_yes_no "add RPM Fusion free and nonfree repos?"; then
        rpm-ostree install \
            https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
            https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    fi
}


# run all functions starting with "setup_1"
for func in $(declare -F | awk '{print $3}' | grep "^setup_1" | sort); do
    $func
done

stty sane 2>/dev/null
echo "Done! Reboot and run setup-2.sh"
echo "systemctl reboot"
