# rpm-ostree package layering
# PACKAGES and hooks are embedded by build.sh

setup_2_300_rpm_ostree() {
    local all_packages="@@RPM_OSTREE_PACKAGES@@"
    local selected=""
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
                selected="$selected mesa-va-drivers-freeworld"
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

    # Codecs (from RPM Fusion)
    if step_confirm "install libavcodec-freeworld (H.264/H.265 codec support)?"; then
        selected="$selected libavcodec-freeworld"
    fi

    selected=$(echo "$selected" | xargs)

    # run package hooks
@@RPM_HOOKS@@

    # refresh repo metadata after hooks add repos
    rpm-ostree refresh-md

    # Execute rpm-ostree operations
    if [ -n "$selected" ]; then
        echo ""
        echo "Layering packages"
        rpm-ostree install $selected
    fi

    if [ -z "$selected" ]; then
        echo ""
        echo "No packages selected"
    fi
}
