#!/bin/sh

# Install node_exporter and untar
wget 'https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz'
tar -xzf 'node_exporter-1.6.1.linux-amd64.tar.gz'
rm 'node_exporter-1.6.1.linux-amd64.tar.gz'

# Move the file to /usr/local/bin/
mv 'node_exporter-1.6.1.linux-amd64/node_exporter' /usr/local/bin/

# Configure service file
cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Reload daemon and restart service
systemctl daemon-reload
systemctl start node_exporter.service
systemctl enable node_exporter.service
