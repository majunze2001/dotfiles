#!/usr/bin/env bash
#
# Install pueue and run pueued as a systemd user service.

set -euo pipefail

# Install the pueue daemon and client.
cargo install --locked pueue

# Create a systemd user service for pueued.
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/pueued.service << 'EOF'
[Unit]
Description=Pueue Daemon
After=network.target

[Service]
ExecStart=%h/.cargo/bin/pueued
Restart=on-failure

[Install]
WantedBy=default.target
EOF

# Enable and start the service.
systemctl --user daemon-reload
systemctl --user enable --now pueued
systemctl --user status pueued --no-pager   # confirm "active (running)"

# Keep the service running after logout.
loginctl enable-linger "$(whoami)"
