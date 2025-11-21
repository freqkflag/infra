disable_mlock = true

storage "file" {
  path = "/vault/file"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr = "https://vault.freqkflag.co"
ui = true

default_lease_ttl = "168h"
max_lease_ttl = "720h"

audit_device "file" {
  file_path = "/vault/logs/audit.log"
  format    = "json"
  log_raw   = false
  hmac_accessor = true
}
