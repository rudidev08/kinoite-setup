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
