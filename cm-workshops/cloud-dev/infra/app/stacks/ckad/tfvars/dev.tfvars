# Optional variables:
prefix = "ckad-<%= Terraspace.env %>"
agents_size      = "standard_b2s"
agents_count     = "2"
os_disk_size_gb  = "30"
kubernetes_version = "1.20.7"
availability_zones = ["1"] # list(string)
enable_http_application_routing = true