# Source our reusable functions
if [ -f /pr-scripts/functions.sh ]; then
    . /pr-scripts/functions.sh
else
    echo "ERROR: /pr-scripts/functions.sh not found!"
    exit 1
fi

# Get the name of the script without the path
SCRIPT_NAME=$(basename "$0")

# Count the number of running instances of the script (excluding the current one)
NUM_INSTANCES=$(pgrep -f "${SCRIPT_NAME}" | grep -v "$$" | wc -l)

# If more than one instance is found, exit
if [ "$NUM_INSTANCES" -gt 1 ]; then
    log_say "${SCRIPT_NAME} is already running, exiting."
    exit 1
fi

# Print our PR Logo
print_logo

# Set our LED to waiting for Internet
led_signal_waiting_for_net

# Wait for Internet connection
wait_for_internet

# Wait for opkg to finish
wait_for_opkg

# Update opkg
update_opkg

# If nothing is set for REPO we set it to main
if [ -z "${REPO}" ]; then
    REPO="main"
fi

# Download our startup.tar.gz with our startup scripts and load them in
log_say "Downloading startup.tar.gz"
wget -q -O /tmp/startup.tar.gz "https://github.com/PrivateRouter-LLC/script-repo/raw/${REPO}/startup-scripts/startup.tar.gz"
log_say "Extracting startup.tar.gz"
tar -xzf /tmp/startup.tar.gz -C /etc
rm /tmp/startup.tar.gz

# Rewrite our rc.local to clean it up
if [ -f /pr-scripts/templates/rc.local.clean ]; then
    cat </pr-scripts/templates/rc.local.clean >/etc/rc.local
else
    # Just in case!
    echo "" > /etc/rc.local
fi

# Alert we are about to reboot
led_signal_waiting_for_drive
led_signal_waiting_for_net
sleep 30
reboot

exit 0
