resource "null_resource" "recreate_trigger" {
  triggers = {
    always_recreate = timestamp()
  }
}

resource "random_string" "stateless_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true

  keepers = {
    always_recreate = null_resource.recreate_trigger.id
  }
}
