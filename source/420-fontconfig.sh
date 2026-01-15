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
