prometheus.remote_write "to_mimir" {
  endpoint {
    url = env("RW_URL")

    headers = {
      "X-Scope-OrgID" = env("TENANT_ID"),
    }

    remote_timeout = "30s"

    queue_config {
      capacity             = 20000
      max_shards           = 8
      max_samples_per_send = 5000
      min_shards           = 1
    }
  }

  wal {
    truncate_frequency = "2h"
    min_keepalive_time = "5m"
    max_keepalive_time = "8h"
  }

  external_labels = {
    customer = env("TENANT_ID"),
    source   = "oracle-db-exporter",
    env      = "local",
  }
}

prometheus.scrape "oracle" {
  targets = [
    { __address__ = "oracle_exporter:9161", instance = "oracle-local" },
  ]
  scrape_interval = "30s"
  scrape_timeout  = "25s"

  forward_to = [prometheus.remote_write.to_mimir.receiver]
}
