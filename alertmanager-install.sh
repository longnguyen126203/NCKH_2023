#!/bin/shlertmanage
#https://devopscube.com/prometheus-alert-manager/

# Install alertmanager and untar
wget 'https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.linux-amd64.tar.gz'
tar -xzf 'alertmanager-0.27.0.linux-amd64.tar.gz'
rm 'alertmanager-0.27.0.linux-amd64.tar.gz'

# Move the binaries to /usr/local/bin/
mv 'alertmanager-0.27.0.linux-amd64/alertmanager' /usr/local/bin/
mv 'alertmanager-0.27.0.linux-amd64/amtool' /usr/local/bin/

# Create the storage directory
mkdir /var/lib/alertmanager
mkdir /etc/alertmanager

# Configure service file
cat > /etc/systemd/system/alertmanager.service << EOF
[Unit]
Description=Alert Manager
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/alertmanager \
--config.file /etc/alertmanager/alertmanager.yml \
--storage.path /var/lib/alertmanager

[Install]
WantedBy=multi-user.target
EOF

# Configure alertmanager
cat > /etc/alertmanager/alertmanager.yml << EOF
global:
  resolve_timeout: 1m

route:
  receiver: 'email-notifications'

receivers:
- name: 'email-notifications'
  email_configs:
    - to: 'arunlal@abcdefg.com'
      from: 'email@devopsproject.dev'
      smarthost: 'email-smtp.us-west-2.amazonaws.com:587'
      auth_username: '$SMTP_user_name'
      auth_password: '$SMTP_password'

      send_resolved: false
EOF

#group_by:[]
#group_wait:
#group_interval:
#repeat_interval:

# Reload daemon and restart services
systemctl daemon-reload
systemctl start alertmanager.service
systemctl enable alertmanager.service
