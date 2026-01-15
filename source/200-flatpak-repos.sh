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
