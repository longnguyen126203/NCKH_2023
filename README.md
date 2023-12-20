# Prometheus Grafana

# 1. Prometheus

**Prometheus**  là một công cụ mã nguồn mở dùng để giám sát và thông báo metrics (thông số và móc thời gian) của hệ thống chẳng hạn như CPU, RAM, lưu lượng mạng,...

**Bổ sung thêm khi đọc tài liệu…..**

## Cài đặt Prometheus

Tạo user prometheus

```
useradd -M -s /bin/false prometheus
```
		
Tải Prometheus về bằng ``wget`` và giải nén

```
wget https://github.com/prometheus/prometheus/releases/download/v2.47.0/prometheus-2.47.0.linux-amd64.tar.gz
tar -zxf prometheus-2.47.0.linux-amd64.tar.gz
```

Chép file Prometheus và ``promtool`` va ``/usr/local/bin/`` và cấp quyền cho người dùng prometheus:

```
cp prometheus-2.47.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.47.0.linux-amd64/promtool /usr/local/bin/
chown -R prometheus:prometheus /usr/local/bin/prometheus
chown -R prometheus:prometheus /usr/local/bin/promtool
```
		
Tạo folder ``/var/lib/prometheus`` và cấp quyền cho người dùng prometheus

```
mkdir /var/lib/prometheus
chown -R prometheus:prometheus /var/lib/prometheus/
```

		
Chép folder ``consoles`` và ``console_libraries`` vào

```
cp -r prometheus-2.47.0.linux-amd64/consoles/ /var/lib/prometheus/

cp -r prometheus-2.47.0.linux-amd64/console_libraries/ /var/lib/prometheus/

chown -R prometheus:prometheus /var/lib/prometheus/
```
    

Tạo folder ``/etc/prometheus:``

```
mkdir /etc/prometheus
```
		
Chép folder ``consoles`` và ``console_libraries`` vào

```
cp -r prometheus-2.47.0.linux-amd64/consoles/ /etc/prometheus/

cp -r prometheus-2.47.0.linux-amd64/console_libraries/ /etc/prometheus/
```

		
Chép file prometheus.yml vao /etc/prometheus và cấp quyền cho người dùng prometheus:

```
cp prometheus-2.47.0.linux-amd64/prometheus.yml /etc/prometheus/

chown -R prometheus:prometheus /etc/prometheus/
```

		
Tạo file prometheus.service vao /etc/systemd/system/ có nội dung như sau:

```
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
```
		
Khởi động lại daemon và khởi động prometheus

```
systemctl daemon-reload
systemctl start prometheus.service
systemctl enable prometheus.service
```

---
	
# 2.Prometheus-Node Exporter
## Cài đặt Node Exporter
Cài đặt PromNode Exporter về và giải nén:

```
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar -xzf node_exporter-1.6.1.linux-amd64.tar.gz
```
	
Tạo người dùng Promnode-exporter

```
useradd -M -s /bin/false node_exporter
```

(``-M`` tạo người dùng không chứa thư mục home | ``-s`` là thiết lập shell mặc định tài khoản là ``/bin/false``)
		
Cap quyen chua file node_exporter cho người dùng node_exporter:

```
chown node_exporter:node_exporter node_exporter-1.6.1.linxux-amd64/node_exporter
```
		
Di chuyen file den /usr/local/bin/
	
```
mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
```
		
Tạo file node_exporter.service tai/etc/systemd/system/ với nội dung như sau:

```
vim /etc/systemd/system/node_exporter.service
```

```
[Unit]
Description=Node Exporter
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
		
[Install]
WantedBy=multi-user.target
```

Khởi động lại daemon va khởi động dịch vụ:
	
```
systemctl daemon-reload

systemctl start node_exporter.service
		
systemctl enable node_exporter.service
```
		
Thêm những dòng sau để lấy thông tin sau khi khởi động và đưa lên grafana vào file/etc/prometheus/prometheus.yml:

```
#my global config
global:
scrape_interval: 15s #Set the scrape_interval to very 15 seconds.
Default is every 1 minute.
evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
# scrape_timeout is set to the global default (10s).
    		  
# Altertmanager configuration
alerting:
alertmanagers:
- static_configs:
- tagerts:
# - alertmanager:9093
# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
# - "first_rules.yml"
# - "second_rules.yml"
# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
# The job name is added as a label `job=<job_name>` to any timeseries 
scraped from this config.
- job_name: "prometheus"
    		  
# metrics_path defaults to '/metrics'
# scheme defaults to 'http'.
    			
static_configs:
- targets: ["localhost:9090"]
    			  
- job_name: "Node Exporter"
static_configs:
- targets: ["localhost:9100"]
```

Để kiểm tra prometheus va prometheusNode-Exporter đã hoạt động chưa:

Gõ ``<IP address>:9090``

Trường hợp lỗi trùng cổng

Xác minh thông qua
```
systemctl status node_exporter.service
```

Để khắc phục lỗi này:
```
vi /etc/systemd/system/node_exporter.service
```

Tại dòng ExecStart, thêm cờ ``--web.listen-address=:7676``

7676 là port mới để chạy node-exporter
Làm điều này rồi lưu ý đổi port tương ứng trong /etc/promethes/prometheus.yml*

---		

# 3.Prometheus-WMI Exporter(Windows Management Instrumentation)

- Quản lý dữ liệu và hệ thống trên hệ điều hành Windows
- WMI Exporter là third-party Prometheus exporter cho Windows

## Tải xuống và cài đặt:

```
https://github.com/prometheus-community/windows_exporter/releases/download/v0.24.0/windows_exporter-0.24.0-386.exe
```

Click chuột --> Run để chạy chương trình
	
Sau khi chạy lên thì xuất hiện màn hình cmd

### Kiểm tra exporter đã chạy chưa:

Vào trình duyệt gõ ``localhost:9182``

Cấu hình prometheus tương ứng:

Thêm thông tin vào file ``/etc/prometheus/prometheus.yml``:

```
# my global config
global:
scrape_interval: 15s #Set the scrape_interval to very 15 seconds.
Default is every 1 minute.
evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
# scrape_timeout is set to the global default (10s).
    		  
# Alertmanager configuration
alerting:
alertmanagers:
- static_configs:
- tagerts:
# - alertmanager:9093
# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
# - "first_rules.yml"
# - "second_rules.yml"
# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
# The job name is added as a label `job=<job_name>` to any timeseries 
scraped from this config.
- job_name: "prometheus"
    		  
# metrics_path defaults to '/metrics'
# scheme defaults to 'http'.
    			
static_configs:
- targets: ["localhost:9090"]
    			  
- job_name: "wmi_exporter"
static_configs:
- targets: ["localhost:9182"]
```
		
Sau đó chạy lại trên cmd:

```
prometheus.exe
```

Nếu có thông báo ``server is ready to receive web requests`` là thành công

Cuối cùng, chạy trên trình duyệt ``<địa chỉ ip>:9090`` --> vào targets để kiểm tra.

---
	
# 4.Retrieving Metrics
## Data Model:
- Prometheus lữu trữ dữ liệu như là chuỗi thời gian
- Mỗi chuỗi thời gian được xác định bởi tên số liệu và các lables
	- Labels là khóa và cặp giá trị
		<metric name? {key=value, key=value,..}

			ví dụ: auth_api_hit {count=1, time_taken=800}
			
## Data Types in Prometheus:
- Scalar : Float và String
	Store:

		ví dụ: prometheus_http_requests_total{code="200", job="prometheus"}
			Query:
				prometheus_http_requests_total{code=~"2.*",job="prometheus"}
				prometheus_http_requests_total{code=200,job="prometheus"}
				
- Instant Vectors: 

		vi dụ: auth_api_hit 5
					auth_api_hit {count=1, time_taken=800} 1
				
- Range Vectors:
    label_name[time_spec]
    auth_api_hit[5m]
```
Demo: 
- Vào localhost:9100 
- Lấy metrics của node_network_transmit_errs_total{} bất kì sau đó copy sau đó paste vào trang Prometheus và thêm auth_api_hit[30m] vào node_network_transmit_errs_total{30m}
- Các thông số trên được đưa vào file prometheus.yml và hoạt động theo scrape_interval
```
				
## Binary Arithmatic Operators in Prometheus
- Operators: (+), (-), (*), (/)
    - Scalar+Instant Vector
    - Áp dụng đến mọi gái trị của instant vector
        
```
Demo:
- Vào Prometheus nhập metrics vào thanh tìm kiếm và chọn bất kì một total
- Tại đây sẽ có một giá trị tương ứng, sau đó thực hiện phép tính bằng cách thực hiện phép toán và một giá trị vào cuối total
- Instant Vector + Instant Vector
Áp dụng đến mọi giá trị của vector bên trái và nó nối với giá trị trong vector bên phải.
```

## Binary Comparison Operators in Prometheus
- Comparison Binary Operators (==), (!=), (>), (<), (>=), (<=)
```
	ví dụ: 1==1 		1:True
		    1==2		0:False
```
## Set Binary Operators in Prometheus(and, or, unless)
- Set binary operators có thể được áp dụng duy nhất trên Instant Vectors
```
Ví dụ: M{a}: 10; M{a}:10
		M{b}:4;	M{c}:4
and: M{a}:10
or: M{a}:10; M{b}:4; M{c}:4
unless: M{b}: 4
```
## Matchers and Selectors in Prometheus
- Filter Machers/Selectors
```
<metric name> {filter_key=value, filter_key=value, ...}
							   and
prometheus_http_requests_total{code=200, job"prometheus"}
```

```
=  Two values must be equal
!= Two values must NOT be equal
=~ Value on left must match be Regular Expression (regex) on right
!~ Value on left must NOT match the Regular Expression (regex) on right

prometheus_http_requests_total{total=~"2.*", job="prometheus"}
```

## Aggregation Operators
- Tổng hợp các yếu tố của một đơn vị Instant Vector
- Kết quả là một Instant Vector mới với các giá trị tổng hợp
```
sum: Tính tổng trên các kích thước
min: Chọn kích thước nhỏ nhất
max: Chọn kích thước lớn nhất
group: Groups elements. Tất cả giá trị trong vector kết quả bằng 1
count_values: Đếm số phần tử có cùng giá trị 
topk: Các elements lớn nhất theo mẫu
bottomk: Các elements nhỏ nhất theo mẫu
stdev: Tìm độ lệch mức độ theo kích thước
stdvar: Tìm thay đổi tiêu chuẩn mức độ theo kích thước
```

```
<Aggregation Operator> (<Instant Vector)
sum(node_cpu_total)

<Aggregation Operator> (Instant Vector) by (<label list>)
sum(node_cpu_total) by (http_code)

<Aggregation Operator> (<Instant Vector) Without (<label list>)
sum(node_cpu_total) without (http_code)
```

## Time	Offets
- Xem và biểu thị prometheus trong quá trình hoạt động
```
prometheus_http_requests_total offset <thôngso>
```

---

# 5.Functions in Prometheus
## Clamping and Checking Functions
- Functions
```
absent(<Instant Vector>): Kiểm tra xem một vector tức thì có bất kỳ members nào không
							Trả về một vector rỗng nếu tham số có các phần tử
ví dụ: absent(node_cpu_seconds_total{cpu="x89d"})
```

```
absent_over_time(<range Vector>): Kiểm tra một vector phạm vi bất kỳ có members nào không
									Trả về một vector rỗng  nếu tham số có các phần tử
vi dụ: 	absent_over_time(node_cpu_seconds_total{cpu="xrff"}[1h])
```

```
abs(<Instant Vector>) Chuyển đổi tất cả các giá trị thành giá trị tuyệt đối của chúng e.g.., -5 to 5
ceil(<Instant Vector>) Chuyển đổi tất cả các giá trị thành số nguyên lớn hơn gần chúng nhất e.g.., 1.6 to 2
floor(<Instant Vector>) Chuyển đổi tất cả các giá trị thành số nguyên nhỏ hơn gần chúng nhất e.g.., 1.6 to 1
clamp(<Instant Vector>, min, max) clamp_min(<Instant Vector>, mi)
								  clamp_max(<Instant Vector>, max)
```

## Delta and iDelta
Functions
```
day_of_month(<Instant Vector>) Đối với mỗi ngày trả về giờ UTC trong tháng 1..31
day_of_week(<Instant Vector>) Đối với mỗi tuần trả về giờ UTC trong tháng 1..7
```

```
delta(<Instant Vector>) Có thể được sử dụng duy nhất với Gauges
idelta(<Range Vector>) Trả về chênh lệch giữa mục đầu tiên và mục cuối cùng
ví dụ: delta(node_cpu_temp[2h])
```

## Sorting and TimeStamp
```
log2(<Instant Vector>) Returns binary logarithm of each scalar value
log10(<Instant Vector>) Returns decimal logarithm of each sacalar value
In(<Instant Vector>) Returns neutral logarithm of each scalar value
sort(<Instant Vector>) Sorts elements in ascending order
sort_desc(<Instant Vector?) Sorts elements in ascending order
		time() Returns a near-current time stamp
timestamp(<Instant Vector>) Returns the time stamp of each time series (element)
```

## Aggregations Over Time
	
```
avg_over_time(<range Vector>) Returns the average of items in a range vector
sum_over_time(<range Vector>) Returns the sum of items in a range vector
min_over_time(<range Vector>) Returns the minimum of items in a range vector
max_over_time(<range Vector>) Returns the maximum of items in a range vector
count_over_time(<range Vector>) Returns the count of items in a range vector

ví dụ: avg_over_time(node_cpu_seconds_total{cpu="0"}[2h])
```	

# 6.Alerting
## Alerts overview
- Bắt đầu từ Prometheus gửi tín hiệu xuống file .yml(Alerts Definition File) bằng PromQL
- Tiếp theo Prometheus dựa vào Alert Manager để quản lý(Email, Slack, PagerDuty, WebHook)
- Server là nơi chứa Prometheus liên lạc qua lại với nhau nhằm gửi alert nhanh nhất để đến alert manager

## Defining Alert Rules

```
In Linux put the alerts rule files in /etc/prometheus/rules
```

```
- In Windows and Mac, create a folder called "rule" or "rules" for the rule .yml files
- Finder in Mac is like File Explorer in Windows /usr/local/etc 
```

```
add in alerts.yml:
group:
	- name: Alerts
	rules:
	  - alert: Is Node Exporter Up
	    expr: up{job="node_exporter"}==0
```

```
Open prometheus.yml add:
rule_files:
	- "rule/alerts.yml"
```

```
In linux: sudo systemctl restart prometheus
```

## Defining a Time Threshold
The "for" expression
Demo:

```
group:
  - name: Alerts
    rules:
	- alert: Is Node Exporter Up
	  expr: up{job="node_exporter"} == 0
	  for: 5m
```

Use the "for" expression to define a time threshold

## Labels, Annotations, and Templates
Demo:

```
group:
  - name: Alerts
    rules:
    - alert: Is Node Exporter Up
      expr: up{job="node_exporter"} == 0
      for: 0m
      labels:
        team: Team Alpha
        severiry: Critical
	  annotations:
	    summary: "{{ $labels.instance}} Is Down"
		desription: "Team Alpha has to restart the server {{ $labels }} VALUE: {{ $value }}"
```

```
systemctl services restart prometheus
```

## What is Alert Manager

## Installing Alert Manager on Windows
Vào trang web:

```
https://prometheus.io/download
```

```
Chọn alertmanager bên phải
https://github.com/prometheus/alertmanager/releases/download/v0.26.0/alertmanager-0.26.0.windows-amd64.zip
```

## Installing After Manager on Mac Computers

## Installing Alert Manager on Ubuntu
Tải và cài đặt Alert Manager

```
wget https://github.com/prometheus/alertmanager/releases/download/v0.26.0/alertmanager-0.26.0.linux-386.tar.gz
tar -xzf alertmanager-0.26.0.linux-386.tar.gz
```

Tạo folder /var/lib/alertmanager và cấp quyền cho người dùng prometheus

```
cd alertmanager-0.26.0.linux-386
mkdir /var/lib/alertmanager
mv * /var/lib/alertmanager/
cd /var/lib/alertmanager/
mkdir data
chown -R promethes:prometheus /var/lib/alertmanager
chown -R promethes:promethes /var/lib/alertmanager/*
chown -R 755 /var/lib/alertmanager
chown -R 755 /var/lib/alertmanager/*
```

Tạo alertmanager.service vào ``/etc/systemd/system/

```
nano /etc/systemd/system/alertmanager.service
```

```
[Unit]
Description=Prometheus Alert Manager
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/var/lib/alertmanager/alertmanager --storage.path="/var/lib/alertmanager/data" --config.file="/var/lib/alertmanager/alertmanager.yml"

SyslogIdentifier=prometheus_alert_manager
Restart=always

[Install]
WantedBy=multi-user.target
```

Khởi động lại daemon và khởi động dịch vụ:

```
systemctl daemon-reload
systemctl start alertmanager
systemctl enable alertmanager
```
	
## Blackbox_Exporter
Tải và cài đặt Blackbox_Exporter

```
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.24.0/blackbox_exporter-0.24.0.freebsd-amd64.tar.gz
tar -zxf blackbox_exporter-0.24.0.freebsd-amd64.tar.gz
```

Di chuyển file đến thư mục /usr/local/bin

```
mv blackbox_exporter /usr/local/bin
```

Tạo thư mục và chuyển đến /etc/blackbox_exporter

```
mkdir -p /etc/blackbox_exporter
mv blackbox.yml /etc/blackbox
```

Tạo người dùng và cấp quyền cho người dùng vào /usr/local/bin/blackbox_exporter

```
useradd -rs /bin/false blackbox
chown blackbox:blackbox /usr/local/bin/blackbox_exporter
chown -R blackbox:blackbox /etc/blackbox/*
```

Thêm những dòng sau của ``blackbox.service`` trong ``/lib/systemd/system``

```
cd /lib/systemd/system
touch blackbox.service
```

```
[Unit]
Description=Blackbox Exporter Service
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
```

Khởi động lại daemon và khởi động dịch vụ

```
systemctl daemon-reload
systemctl enable blackbox.service
systemctl start blackbox.service
```

Truy cập vào trình duyệt để kiểm tra

```
http://localhost:9115
```

## Download & Install Prometheus MySQL Exporter

```
curl -s https://api.github.com/repos/prometheus/mysqld_exporter/releases/latest   | grep browser_download_url   | grep linux-amd64   | cut -d '"' -f 4   | wget -qi -
tar xvf mysqld_exporter*.tar.gz
mv  mysqld_exporter-*.linux-amd64/mysqld_exporter /usr/local/bin/
chmod +x /usr/local/bin/mysqld_exporter
```

## Create Prometheus Exporter Database User to Access the Database, Scrape Metrics & Provide Grants

```
CREATE USER 'mysqld_exporter'@'<PrometheusHostIP>' IDENTIFIED BY 'StrongPassword' WITH MAX_USER_CONNECTIONS 2;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'mysqld_exporter'@'<PrometheusHostIP>';
FLUSH PRIVILEGES;
EXIT
```

## Configure the Database Credentials

```
vim /etc/.mysqld_exporter.cnf
```

Add Add the username and password of the user created and the ScaleGrid MySQL server you want to monitor.

```
[client]
user=mysqld_exporter
password=StrongPassword
host=SG-mysqltestcluster-123456.servers.mongodirector.com
```

Set ownership permissions

```
chown root:prometheus /etc/.mysqld_exporter.cnf
```

## Create systemd Unit File

```
vim /etc/systemd/system/mysql_exporter.service
```

Add the following content:

```
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
```

Reload systemd and start mysqld_exporter service:

```
systemctl daemon-reload
systemctl enable mysql_exporter
systemctl start mysql_exporter
```

## Configure MySQL Endpoint to be Scraped by Prometheus

```
scrape_configs:
	  - job_name: mysql_server1
	    static_configs:
	      - targets: ['localhost:9104']
	        labels:
	          alias: db1
```

```
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
```
