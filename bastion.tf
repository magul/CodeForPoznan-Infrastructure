resource "aws_security_group" "bastion" {
  name   = "bastion"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  depends_on = [
    aws_vpc.main,
  ]
}

data "template_cloudinit_config" "bastion" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content = <<TEMPLATE
ssh_authorized_keys:
%{for key in [
    module.tomasz_magulski.public_key,
    module.artur_tamborski.public_key,
    module.wojciech_patelka.public_key,
]~}
  - ${key}
%{endfor~}
    TEMPLATE
}
}

resource "aws_instance" "bastion" {
  ami              = "ami-035966e8adab4aaad" # Ubuntu 18.04 LTS in eu-west-1
  instance_type    = "t2.nano"
  subnet_id        = aws_subnet.public_a.id
  user_data_base64 = data.template_cloudinit_config.bastion.rendered
  vpc_security_group_ids = [
    aws_security_group.bastion.id,
    aws_default_security_group.main.id,
  ]

  depends_on = [
    aws_subnet.public_a,
    aws_security_group.bastion,
    aws_default_security_group.main,
  ]
}

resource "aws_eip" "bastion" {
  vpc                       = true
  instance                  = aws_instance.bastion.id
  associate_with_private_ip = aws_instance.bastion.private_ip

  depends_on = [
    aws_internet_gateway.main,
    aws_instance.bastion,
  ]
}

resource "aws_route53_record" "bastion" {
  name    = "bastion.codeforpoznan.pl"
  type    = "A"
  zone_id = aws_route53_zone.codeforpoznan_pl.id
  ttl     = "300"
  records = [aws_eip.bastion.public_ip]

  depends_on = [
    aws_route53_zone.codeforpoznan_pl,
    aws_eip.bastion,
  ]
}
