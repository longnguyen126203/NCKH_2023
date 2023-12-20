#!/bin/sh

# Download blackbox_exporter and untar
wget 'https://github.com/prometheus/blackbox_exporter/releases/download/v0.24.0/blackbox_exporter-0.24.0.linux-amd64.tar.gz'
tar -zxf 'blackbox_exporter-0.24.0.linux-amd64.tar.gz'
rm 'blackbox_exporter-0.24.0.linux-amd64.tar.gz'

# Move the binary to /usr/local/bin
mv 'blackbox_exporter-0.24.0.linux-amd64'/blackbox_exporter /usr/local/bin

# Move the config file to /etc/blackbox
mkdir /etc/blackbox
mv 'blackbox_exporter-0.24.0.linux-amd64'/blackbox.yml /etc/blackbox

# Configure ownership for the service
useradd -M -s /bin/false blackbox
chown blackbox:blackbox /usr/local/bin/blackbox_exporter
chown blackbox:blackbox /etc/blackbox/blackbox.yml

# Configure service file
cat > /etc/systemd/system/blackbox.service << EOF
[Unit]
Description=Blackbox Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=blackbox
Group=blackbox
ExecStart=/usr/local/bin/blackbox_exporter \
  --config.file=/etc/blackbox/blackbox.yml \
  --web.listen-address=":9115"

Restart=always

[Install]
WantedBy=multi-user.target
EOF

#Configure yml file
cat << EOF
http_custom_ca_example:
    prober: http
    http:
      preferred_ip_protocol: "ip4"
      tls_config:
        #cert_file: "/etc/blackbox_exporter/fullchain1.pem"
        #key_file: "/etc/blackbox_exporter/privkey1.pem"
        insecure_skip_verify: true
        ca_file: "/etc/blackbox_exporter/STAR_dlu_edu_vn.crt" | echo >> /etc/blackbox/blackbox.yml
EOF | echo >> /etc/blackbox/blackbox.yml

# Reload daemon and restart service
systemctl daemon-reload
systemctl start blackbox.service
systemctl enable blackbox.service
