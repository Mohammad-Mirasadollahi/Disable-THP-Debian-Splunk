#!/bin/bash

# Script to create a systemd service that disables Transparent Huge Pages (THP) on Debian

SERVICE_FILE="/etc/systemd/system/disable-thp.service"

echo "Creating systemd service to disable THP permanently..."

sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Disable Transparent Huge Pages (THP)
After=sysinit.target local-fs.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled"
ExecStart=/bin/sh -c "echo never > /sys/kernel/mm/transparent_hugepage/defrag"
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd to recognize the new service
echo "Reloading systemd..."
sudo systemctl daemon-reload

# Enable the service to run at startup
echo "Enabling disable-thp service..."
sudo systemctl enable disable-thp

# Start the service immediately
echo "Starting disable-thp service..."
sudo systemctl start disable-thp

# Step 3: Verify the Changes
ENABLED_STATUS=$(cat /sys/kernel/mm/transparent_hugepage/enabled)
DEFRAG_STATUS=$(cat /sys/kernel/mm/transparent_hugepage/defrag)

if [[ "$ENABLED_STATUS" == *"[never]"* ]] && [[ "$DEFRAG_STATUS" == *"[never]"* ]]; then
    echo "THP has been successfully disabled."
else
    echo "Failed to disable THP."
fi
