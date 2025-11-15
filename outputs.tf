output "ssh_tunnel" {
  value       = "ubuntu@${aws_route53_record.bastion.name} -L 15432:${aws_db_instance.db.address}:${aws_db_instance.db.port}"
  description = <<-DESCRIPTION
    https://github.com/hashicorp/terraform/issues/8367
    before running terraform create a ssh tunel
  DESCRIPTION
}
