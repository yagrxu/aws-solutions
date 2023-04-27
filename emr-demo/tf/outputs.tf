
################################################################################
# Instance Group
################################################################################

output "group_cluster_arn" {
  description = "The ARN of the cluster"
  value       = module.emr_cluster.cluster_arn
}

output "group_cluster_id" {
  description = "The ID of the cluster"
  value       = module.emr_cluster.cluster_id
}

output "group_cluster_core_instance_group_id" {
  description = "Core node type Instance Group ID, if using Instance Group for this node type"
  value       = module.emr_cluster.cluster_core_instance_group_id
}

output "group_cluster_master_instance_group_id" {
  description = "Master node type Instance Group ID, if using Instance Group for this node type"
  value       = module.emr_cluster.cluster_master_instance_group_id
}

output "group_cluster_master_public_dns" {
  description = "The DNS name of the master node. If the cluster is on a private subnet, this is the private DNS name. On a public subnet, this is the public DNS name"
  value       = module.emr_cluster.cluster_master_public_dns
}

output "group_security_configuration_id" {
  description = "The ID of the security configuration"
  value       = module.emr_cluster.security_configuration_id
}

output "group_security_configuration_name" {
  description = "The name of the security configuration"
  value       = module.emr_cluster.security_configuration_name
}

output "group_service_iam_role_name" {
  description = "Service IAM role name"
  value       = module.emr_cluster.service_iam_role_name
}

output "group_service_iam_role_arn" {
  description = "Service IAM role ARN"
  value       = module.emr_cluster.service_iam_role_arn
}

output "group_service_iam_role_unique_id" {
  description = "Stable and unique string identifying the service IAM role"
  value       = module.emr_cluster.service_iam_role_unique_id
}

output "group_autoscaling_iam_role_name" {
  description = "Autoscaling IAM role name"
  value       = module.emr_cluster.autoscaling_iam_role_name
}

output "group_autoscaling_iam_role_arn" {
  description = "Autoscaling IAM role ARN"
  value       = module.emr_cluster.autoscaling_iam_role_arn
}

output "group_autoscaling_iam_role_unique_id" {
  description = "Stable and unique string identifying the autoscaling IAM role"
  value       = module.emr_cluster.autoscaling_iam_role_unique_id
}

output "group_iam_instance_profile_iam_role_name" {
  description = "Instance profile IAM role name"
  value       = module.emr_cluster.iam_instance_profile_iam_role_name
}

output "group_iam_instance_profile_iam_role_arn" {
  description = "Instance profile IAM role ARN"
  value       = module.emr_cluster.iam_instance_profile_iam_role_arn
}

output "group_iam_instance_profile_iam_role_unique_id" {
  description = "Stable and unique string identifying the instance profile IAM role"
  value       = module.emr_cluster.iam_instance_profile_iam_role_unique_id
}

output "group_iam_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = module.emr_cluster.iam_instance_profile_arn
}

output "group_iam_instance_profile_id" {
  description = "Instance profile's ID"
  value       = module.emr_cluster.iam_instance_profile_id
}

output "group_iam_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = module.emr_cluster.iam_instance_profile_unique
}

output "group_managed_master_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the managed master security group"
  value       = module.emr_cluster.managed_master_security_group_arn
}

output "group_managed_master_security_group_id" {
  description = "ID of the managed master security group"
  value       = module.emr_cluster.managed_master_security_group_id
}

output "group_managed_slave_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the managed slave security group"
  value       = module.emr_cluster.managed_slave_security_group_arn
}

output "group_managed_slave_security_group_id" {
  description = "ID of the managed slave security group"
  value       = module.emr_cluster.managed_slave_security_group_id
}

output "group_managed_service_access_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the managed service access security group"
  value       = module.emr_cluster.managed_service_access_security_group_arn
}

output "group_managed_service_access_security_group_id" {
  description = "ID of the managed service access security group"
  value       = module.emr_cluster.managed_service_access_security_group_id
}
