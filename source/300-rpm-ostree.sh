# rpm-ostree package layering
# PACKAGES and hooks are embedded by build.sh

setup_2_300_rpm_ostree() {
    local all_packages="@@RPM_OSTREE_PACKAGES@@"
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

    # ffmpeg (from RPM Fusion)
    step "codecs"
    if confirm_yes_no "replace ffmpeg-free with ffmpeg (full codec support)?"; then
        install_ffmpeg="yes"
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
