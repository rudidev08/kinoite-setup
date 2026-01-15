# Step counter for progress display
CURRENT_STEP=0
TOTAL_STEPS=@@TOTAL_STEPS@@

step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo ""
    echo "[$CURRENT_STEP/$TOTAL_STEPS] $1"
}

# Combined step counter with yes/no confirmation
step_confirm() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    while true; do
        read -p "[$CURRENT_STEP/$TOTAL_STEPS] $1 [Y/n]: " yn < /dev/tty
        yn=${yn:-y}
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# confirms with user if to run a function or not
# default to yes if empty
confirm_yes_no() {
    while true; do
        # /dev/tty is needed if ran via curl
        read -p "$1 [Y/n]: "  yn < /dev/tty
        yn=${yn:-y}
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}
