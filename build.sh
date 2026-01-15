#!/bin/bash

# Build script that creates setup-1.sh (pre-reboot) and setup-2.sh (post-reboot)

SOURCE_DIR="source"
DATA_DIR="packages"

# Read rpm-ostree packages (filter comments/empty lines, join with spaces)
RPM_PACKAGES=$(grep -v '^#' "$DATA_DIR/rpm-ostree-packages" | grep -v '^$' | tr '\n' ' ' | sed 's/ $//')

# Read repo contents
REPO_1PASSWORD=$(cat "$DATA_DIR/repos/1password.repo")
REPO_VSCODE=$(cat "$DATA_DIR/repos/vscode.repo")

# Read flatpaks (filter comments/empty lines, join with spaces)
FLATPAKS=$(grep -v '^#' "$DATA_DIR/flatpaks" | grep -v '^$' | tr '\n' ' ' | sed 's/ $//')

# Read appimages (filter comments/empty lines, keep newlines)
APPIMAGES=$(grep -v '^#' "$DATA_DIR/appimages" | grep -v '^$')

# Generate rpm-ostree hooks from packages/hooks/*.sh
HOOKS_FILE=$(mktemp)
shopt -s nullglob
for hook in "$DATA_DIR/hooks"/*.sh; do
    pkg=$(basename "$hook" .sh)
    echo "    if [[ \"\$selected\" == *\"$pkg\"* ]]; then" >> "$HOOKS_FILE"
    cat "$hook" >> "$HOOKS_FILE"
    echo "    fi" >> "$HOOKS_FILE"
done

build_script() {
    local output="$1"
    local pattern="$2"
    local setup_prefix="$3"
    local end_message="$4"

    # Header
    cat > "$output" << 'EOF'
#!/bin/bash

# Cache sudo credentials
sudo -v

EOF

    # Helpers (000-*)
    for file in "$SOURCE_DIR"/000-*.sh; do
        [ -f "$file" ] || continue
        cat "$file" >> "$output"
        echo "" >> "$output"
    done

    # Phase-specific scripts
    for file in "$SOURCE_DIR"/$pattern-*.sh; do
        [ -f "$file" ] || continue
        cat "$file" >> "$output"
        echo "" >> "$output"
    done

    # Main loop
    cat >> "$output" << EOF

# run all functions starting with "setup_${setup_prefix}"
for func in \$(declare -F | awk '{print \$3}' | grep "^setup_${setup_prefix}" | sort); do
    \$func
done

$end_message
EOF

    # Replace placeholders
    sed -i "s|@@RPM_OSTREE_PACKAGES@@|$RPM_PACKAGES|g" "$output"
    sed -i "s|@@FLATPAKS@@|$FLATPAKS|g" "$output"

    # Replace @@RPM_HOOKS@@ with hooks file content
    awk -v hooks="$(cat "$HOOKS_FILE")" '{gsub(/@@RPM_HOOKS@@/, hooks); print}' "$output" > "$output.tmp" && mv "$output.tmp" "$output"

    # Replace repo placeholders last (they may be inside hooks) - use awk to avoid escaping issues
    awk -v repo="$REPO_1PASSWORD" '{gsub(/@@1PASSWORD_REPO@@/, repo); print}' "$output" > "$output.tmp" && mv "$output.tmp" "$output"
    awk -v repo="$REPO_VSCODE" '{gsub(/@@VSCODE_REPO@@/, repo); print}' "$output" > "$output.tmp" && mv "$output.tmp" "$output"

    # Count and replace @@TOTAL_STEPS@@
    # For setup-2: packages + fixed steps (GPU, codecs, flatpaks, wallpapers, fontconfig)
    local num_packages=$(echo $RPM_PACKAGES | wc -w)
    local fixed_steps=$(grep -c 'step "' "$output")  # counts step() calls (not step_confirm in loops)
    local total_steps=$((num_packages + fixed_steps))
    sed -i "s|@@TOTAL_STEPS@@|$total_steps|g" "$output"

    chmod +x "$output"
}

# Build setup-1.sh (pre-reboot: 1xx-2xx steps)
build_script "setup-1.sh" "[12][0-9][0-9]" "1" 'stty sane 2>/dev/null
echo "Done! Reboot and run setup-2.sh"
echo "systemctl reboot"'

# Build setup-2.sh (post-reboot: 3xx-4xx steps)
build_script "setup-2.sh" "[34][0-9][0-9]" "2" "stty sane 2>/dev/null
echo \"\"
echo \"Done! AppImages to download:\"
echo \"\"
cat << 'APPIMAGES_EOF'
$APPIMAGES
APPIMAGES_EOF"

rm -f "$HOOKS_FILE"

echo "Built setup-1.sh and setup-2.sh"
