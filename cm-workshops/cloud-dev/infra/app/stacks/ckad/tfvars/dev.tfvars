# Optional variables:
prefix = "ckad-<%= Terraspace.env %>"
agents_size      = "standard_b2s"
agents_count     = "2"
os_disk_size_gb  = "30"
kubernetes_version = "1.20.7"
availability_zones = ["1"] # list(string)
enable_http_application_routing = false
dns_zone_name = "potsdam-softwareentwicklung.de"
dns_a_records_ips = ["20.79.66.35"]
dns_a_records = ["kubernetes", "argocd", "agify"]