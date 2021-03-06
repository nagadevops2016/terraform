#
# LC
#
output "launch_configuration_id" {
  description = "The ID of the launch configuration"
  value       = module.asg_new.launch_configuration_id
}

output "launch_configuration_name" {
  description = "The ID of the launch configuration"
  value       = module.asg_new.launch_configuration_name
}

#
# ASG
#
output "autoscaling_group_id" {
  description = "The ID of the launch configuration"
  value       = module.asg_new.autoscaling_group_id
}

output "autoscaling_group_name" {
  description = "The ID of the launch configuration"
  value       = module.asg_new.autoscaling_group_name
}
