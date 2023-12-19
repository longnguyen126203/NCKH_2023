# Download blackbox_exporter va giai nen
curl -o "blackbox_exporter-0.24.0.windows-amd64.zip" "https://github.com/prometheus/blackbox_exporter/releases/download/v0.24.0/blackbox_exporter-0.24.0.windows-amd64.zip"
Expand-Archive .\blackbox_exporter-0.24.0.windows-amd64.zip .

# Chay file
.\blackbox_exporter-0.24.0.linux-amd64\blackbox_exporter.exe
