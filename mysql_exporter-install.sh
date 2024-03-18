#!/bin/sh

# Install mysql_exporter and untar
wget https://api.github.com/repos/prometheus/mysqld_exporter/releases/latest   | grep browser_download_url   | grep linux-amd64   | cut -d '"' -f 4   | wget -qi -
tar -xvf 'mysqld_exporter*.tar.gz'
rm 'mysqld_exporter*.tar.gz'

# Move the file to /usr/local/bin/
mv  mysqld_exporter-*.linux-amd64/mysqld_exporter /usr/local/bin/

# Change ownership permissions
chmod +x /usr/local/bin/mysqld_exporter

# Create Prometheus Exporter Database User to Access the Database, Scrape Metrics & Provide Grants
CREATE USER 'mysqld_exporter'@'<PrometheusHostIP>' IDENTIFIED BY 'StrongPassword' WITH MAX_USER_CONNECTIONS 2;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'mysqld_exporter'@'<PrometheusHostIP>';
FLUSH PRIVILEGES;
EXIT

# Configure the Database Credentials
cat > /etc/.mysqld_exporter.cnf << EOF

# Add Add the username and password of the user created and the ScaleGrid MySQL server you want to monitor.
[client]
user=mysqld_exporter
password=StrongPassword
host=SG-mysqltestcluster-123456.servers.mongodirector.com
EOF

# Set ownership permissions
chown root:prometheus /etc/.mysqld_exporter.cnf

# Create systemd Unit File
cat > /etc/systemd/system/mysql_exporter.service << EOF
[Unit]
	Description=Prometheus MySQL Exporter
	After=network.target
	User=prometheus
	Group=prometheus

	[Service]
	Type=simple
	Restart=always
	ExecStart=/usr/local/bin/mysqld_exporter \
	--config.my-cnf /etc/.mysqld_exporter.cnf \
	--collect.global_status \
	--collect.info_schema.innodb_metrics \
	--collect.auto_increment.columns \
	--collect.info_schema.processlist \
	--collect.binlog_size \
	--collect.info_schema.tablestats \
	--collect.global_variables \
	--collect.info_schema.query_response_time \
	--collect.info_schema.userstats \
	--collect.info_schema.tables \
	--collect.perf_schema.tablelocks \
	--collect.perf_schema.file_events \
	--collect.perf_schema.eventswaits \
	--collect.perf_schema.indexiowaits \
	--collect.perf_schema.tableiowaits \
	--collect.slave_status \
	--web.listen-address=0.0.0.0:9104
	
	[Install]
	WantedBy=multi-user.target
EOF

# Configure MySQL Endpoint to be Scraped by Prometheus
cat > /etc/mysql_exporter/mysql_exporter.yml << EOF

scrape_configs:
	  - job_name: mysql_server1
	    static_configs:
	      - targets: ['localhost:9104']
	        labels:
	          alias: db1

scrape_configs:
	  - job_name: mysql_server1
	    static_configs:
	      - targets: ['localhost:9104']
	        labels:
	          alias: db1
	  - job_name: mysql_server2
	    static_configs:
	      - targets: ['localhost:9105']
	        labels:
	          alias: db2
	  - job_name: mysql_server3
	    static_configs:
	      - targets: ['localhost:9106']
	        labels:
	          alias: db3
EOF

# Reload systemd and start mysqld_exporter service
systemctl daemon-reload
systemctl enable mysql_exporter
systemctl start mysql_exporter
