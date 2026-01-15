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
