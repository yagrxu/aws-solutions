terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.17.1"
    }
  }
  backend "s3" {
    bucket = "yagr-tf-state-log"
    key    = "solutions/dns-ec2-auto-registry"
    region = "us-east-1"
  }
}

resource "aws_iam_role" "ec2_auto_registry_role" {
  name = var.role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_s3_object" "upsert_json" {
  bucket = var.upsert_bucket
  key    = var.upsert_object_key
  source = var.local_json_file_path

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5(var.local_json_file_path)
}

resource "aws_iam_instance_profile" "ec2_auto_registry_role_profile" {
  name = var.profile_name
  role = aws_iam_role.ec2_auto_registry_role.name
}


resource "aws_iam_policy" "route53_update_records" {
  name        = "route53_update_records"
  path        = "/"
  description = "IAM policy for route53"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/${var.zone_id}",
      "Effect": "Allow"
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_route53" {
  role       = aws_iam_role.ec2_auto_registry_role.name
  policy_arn = aws_iam_policy.route53_update_records.arn

  depends_on = [
    aws_iam_policy.route53_update_records, aws_iam_role.ec2_auto_registry_role
  ]
}

resource "aws_instance" "web" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.keypair_name
  security_groups             = [aws_security_group.demo.id]
  subnet_id                   = aws_subnet.demo.id
  iam_instance_profile        = aws_iam_instance_profile.ec2_auto_registry_role_profile.name
  associate_public_ip_address = true
  user_data                   = <<EOF
Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash
touch /tmp/userlog.log
aws s3 cp s3://yagr-demo-sg/route53-demo/upsert.json /tmp/upsert.json >> /tmp/userlog.log
publicIP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
echo $publicIP >>  /tmp/userlog.log
regexstring='s/(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}/hello/gm;t;d'
echo $regexstring >>  /tmp/userlog.log
sed -E $${regexstring/hello/"$publicIP"} <<< `cat /tmp/upsert.json` > /tmp/upsert.json
echo '' >> /tmp/upsert.json
echo "edited upsert.json" >>  /tmp/userlog.log
aws route53 change-resource-record-sets --hosted-zone-id Z00378711D58PVI3H5ZE7 --change-batch file:///tmp/upsert.json >>  /tmp/userlog.log
EOF
  user_data_replace_on_change = true
}

resource "aws_vpc" "demo" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id
}

resource "aws_subnet" "demo" {
  vpc_id     = aws_vpc.demo.id
  cidr_block = "10.0.1.0/24"

}

resource "aws_route_table" "demo" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }

  # depends_on = [
  #   aws_internet_gateway.demo
  # ]
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.demo.id
  route_table_id = aws_route_table.demo.id
}

resource "aws_security_group" "demo" {
  name        = "demo"
  description = "demo"
  vpc_id      = aws_vpc.demo.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}