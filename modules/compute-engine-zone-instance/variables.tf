variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "app_name" {
  type = string
}

variable "app_target_size" {
  type    = number
  default = 1
}

variable "logs_bucket_name" {
  type = string
}
