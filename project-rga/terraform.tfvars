project_id = "trusty-wavelet-441019-i7"
region = "us-west1"
location = "US"
website_bucket_name = "rga-assessment-${random_string.website_suffix.result}"
access_logs_bucket_name = "rga-assessment-access-logs-${random_string.logs_suffix.result}"
gcp_credentials_file = "/home/username/trusty-wavelet-441019-i7-c780b14f875a.json"