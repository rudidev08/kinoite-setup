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
