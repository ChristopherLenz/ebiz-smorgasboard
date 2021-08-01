# Optional variables:
prefix = "cm-cloud-ws-<%= Terraspace.env %>"
agents_size      = "standard_b2ms"
agents_count     = "1"
os_disk_size_gb  = "30"
kubernetes_version = "1.20.5"
availability_zones = ["1"] # list(string)
enable_http_application_routing = true