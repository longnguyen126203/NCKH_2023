#!/bin/sh

# Install prometheus and untar
wget 'https://github.com/prometheus/prometheus/releases/download/v2.48.1/prometheus-2.48.1.linux-amd64.tar.gz'
tar -zxvf 'prometheus-2.48.1.linux-amd64.tar.gz'
rm 'prometheus-2.48.1.linux-amd64.tar.gz'

# Create prometheus user
useradd -M -s /bin/false prometheus

# Give file ownership to user node_exporter
chown -R prometheus:prometheus 'prometheus-2.48.1.linux-amd64/prometheus'

# Move the file to /usr/local/bin/
mv 'prometheus-2.48.1.linux-amd64/prometheus' /usr/local/bin/
mv 'prometheus-2.48.1.linux-amd64/promtool' /usr/local/bin/

# Configure service file
cat > /etc/systemd/system/prometheus.service << EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target
		
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries
			
[Install]
WantedBy=multi-user.target
EOF

# Create config file
cat > /etc/prometheus/prometheus.yml << EOF
# Sample config for Prometheus.

global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
      monitor: 'example'

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets: ['localhost:9093']

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s
    scrape_timeout: 5s

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ['localhost:9090']

  - job_name: node
    # If prometheus-node-exporter is installed, grab stats about the local
    # machine by default.
    static_configs:
      - targets: ['localhost:9100']
EOF

# Reload daemon and restart service
systemctl daemon-reload
systemctl start prometheus.service
systemctl enable prometheus.service
