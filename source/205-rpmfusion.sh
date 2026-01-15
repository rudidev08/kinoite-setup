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
