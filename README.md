# NCKH_2023

# 1. Prometheus

**Prometheus**  là một công cụ mã nguồn mở dùng để giám sát và thông báo metrics (thông số và móc thời gian) của hệ thống chẳng hạn như CPU, RAM, lưu lượng mạng,...

**Bổ sung thêm khi đọc tài liệu…..**

## Cài đặt Prometheus

### Tạo user prometheus

```
useradd -M -s /bin/false prometheus
```
		
### Tải Prometheus về bằng ``wget`` và giải nén

```
wget https://github.com/prometheus/prometheus/releases/download/v2.47.0/prometheus-2.47.0.linux-amd64.tar.gz
tar -zxf prometheus-2.47.0.linux-amd64.tar.gz
```

### Chép file Prometheus và ``promtool`` va ``/usr/local/bin/`` và cấp quyền cho người dùng prometheus:

```
cp prometheus-2.47.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.47.0.linux-amd64/promtool /usr/local/bin/
chown -R prometheus:prometheus /usr/local/bin/prometheus
chown -R prometheus:prometheus /usr/local/bin/promtool
```
		
### Tạo folder ``/var/lib/prometheus`` và cấp quyền cho người dùng prometheus

```
mkdir /var/lib/prometheus
chown -R prometheus:prometheus /var/lib/prometheus/
```

		
### Chép folder ``consoles`` và ``console_libraries`` vào

```
cp -r prometheus-2.47.0.linux-amd64/consoles/ /var/lib/prometheus/

cp -r prometheus-2.47.0.linux-amd64/console_libraries/ /var/lib/prometheus/

chown -R prometheus:prometheus /var/lib/prometheus/
```
    

### Tạo folder ``/etc/prometheus:``

```
mkdir /etc/prometheus
```
		
### Chép folder ``consoles`` và ``console_libries`` vào

```
cp -r prometheus-2.47.0.linux-amd64/consoles/ /etc/prometheus/

cp -r prometheus-2.47.0.linux-amd64/console_libraries/ /etc/prometheus/
```

		
### Chép file prometheus.yml vao /etc/prometheus và cấp quyền cho người dùng prometheus:

```
cp prometheus-2.47.0.linux-amd64/prometheus.yml /etc/prometheus/

chown -R prometheus:prometheus /etc/prometheus/
```

		
### Tạo file prometheus.service vao /etc/systemd/system/ có nội dung như sau:

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
		
### Reload daemon và khởi động prometheus

```
systemctl daemon-reload
systemctl start prometheus.service
systemctl enable prometheus.service
```

---
	
# 2.Prometheus-Node Exporter
## Cài đặt Node Exporter
### Cài đặt PromNode Exporter về và giải nén:

```
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar -xzf node_exporter-1.6.1.linux-amd64.tar.gz
```
	
### Tạo người dùng Promnode-exporter

```
useradd -M -s /bin/false node_exporter
```

(``-M`` tạo người dùng không chứa thư mục home | ``-s`` là thiết lập shell mặc định tài khoản là ``/bin/false``)
		
### Cap quyen chua file node_exporter cho người dùng node_exporter:

```
chown node_exporter:node_exporter node_exporter-1.6.1.linxux-amd64/node_exporter
```
		
### Di chuyen file den /usr/local/bin/
	
```
mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
```
		
## Tạo file node_exporter.service tai/etc/systemd/system/ với nội dung như sau:

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

### Khởi động lại daemon va khởi động dịch vụ:
	
```
systemctl daemon-reload

systemctl start node_exporter.service
		
systemctl enable node_exporter.service
```
		
### Thêm những dòng sau để lấy thông tin sau khi khởi động và đưa lên grafana vào file/etc/prometheus/prometheus.yml:

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

### Để kiểm tra prometheus va prometheusNode-Exporter đã hoạt động chưa:
```
<IP address>:9090 
```

### Nếu trường hợp trùng cổng thì:
```
vi /etc/systemd/system/node_exporter.service
```
>*Tại dòng ExecStart, thêm cờ
`` --web.listen-address=:7676``
7676 là cổng mới để chạy node-exporter
Làm điều này rồi lưu ý đổi port tương ứng trong /etc/promethes/prometheus.yml*
---		

# 3.Prometheus-WMI Exporter(Windows Management Instrumentation)
- Quản lý dữ liệu và hệ thống trên hệ điều hành Windows
- WMI Exporter là third-party Prometheus exporter cho Windows

## Tải xuống và cài đặt:
```
https://github.com/prometheus-community/windows_exporter/releases/download/v0.24.0/windows_exporter-0.24.0-386.exe
```

- Click chuột --> Run để chạy chương trình
	
### Sau khi chạy lên thì xuất hiện màn hình command:
```	
Vào trình duyệt gõ localhost:9182

Copy localhost:9182 --> Past vào màn hình command
Lúc này xuất hiện mục forder có tên giống với cái file đã tải trong đường link bên trên
```

### Them nhung dong sau de lay thong tin sau khi khoi dong va dua len grafana vao file/etc/prometheus/prometheus.yml:
```
# my global config
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
    			  
- job_name: "wmi_exporter"
static_configs:
- targets: ["localhost:9182"]
```
		
### Sau đó chạy lại trên command: prometheus.exe(Có thông báo server is ready to receive web requests) là thành công
### Cuối cùng chạy trên trình duyệt <địa chỉ ip>:9090 --> vào targets để kiểm tra.

---
	
# 4.Retrieving Metrics
## Data Model:
- Prometheus lữu trữ dữ liệu như là chuỗi thời gian
- Mỗi chuỗi thời gian được xác định bởi tên số liệu và các lables
	- Lables là khóa và cặp giá trị
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

## Aggregations OVer Time	
	
