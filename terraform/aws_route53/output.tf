output "hub_ip_address" {
  value = "${aws_instance.hub.public_ip}"
}

output "worker_ip_address" {
  value = "${aws_instance.worker.*.public_ip}"
}

output "alb_fqdn" {
  value = "${aws_lb.hublb.dns_name}"
}

output "hub_url" {
  value = "https://${aws_acm_certificate.lb.domain_name}"
}

resource "aws_iam_access_key" "hub-s3" {
  user    = aws_iam_user.hub-s3.name
}

resource "local_file" "ansible_hosts" {
  content = templatefile("hosts.tpl", {
	hub_ip = aws_instance.hub.public_ip
	hub_private_name = aws_route53_record.hub.name
	ingress_url = "https://${aws_acm_certificate.lb.domain_name}"
	shared_store_ip = aws_efs_mount_target.shared_store.ip_address
	workers = [
	  for i,v in aws_instance.worker:
	  {
		"public_ip" = aws_instance.worker[i].public_ip
		"private_name" = aws_route53_record.worker[i].name
	  }
	]
	# workers = aws_instance.worker
	username = "${var.ssh_user_name}"
	db_host = aws_db_instance.hubdb.address
	db_name = "${var.prefix}hub"
	db_user = "${var.dbusername}"
	db_password = "${var.dbpassword}"
	s3_use_iam = "${var.use_iam_for_s3}"
	s3_endpoint = "s3.amazonaws.com"
	s3_access_key_id = aws_iam_access_key.hub-s3.id
	s3_secret_access_key = aws_iam_access_key.hub-s3.secret
	s3_bucket = aws_s3_bucket.hubdata.bucket
	s3_region = "${var.region}"
  })
  filename = "hosts"
  file_permission = 0600
}