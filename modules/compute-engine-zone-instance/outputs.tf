output "instance_group_instances" {
  value = google_compute_instance_group_manager.app.instance_group
}

output "log_sink_writer_identity" {
  value = google_logging_project_sink.sink.writer_identity
}
