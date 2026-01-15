# flatpak installs from flathub
# FLATPAKS content is embedded by build.sh

setup_2_400_flatpak() {
    local all_flatpaks="@@FLATPAKS@@"
    local selected=""
    local to_remove=""

    step "flatpaks"

    # Remove pre-installed flatpaks
    local all_removals="@@FLATPAKS_REMOVE@@"
    echo "-- remove --"
    for app in $all_removals; do
        if confirm_yes_no "remove $app?"; then
            to_remove="$to_remove $app"
        fi
    done

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
