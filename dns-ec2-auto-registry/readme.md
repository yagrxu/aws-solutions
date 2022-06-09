# How to automatically register EC2 public IP to Route53


## Use Case

You have an EC2 instance with automatically assigned public IP. The instance is standalone EC2 or an entry point of a distributed cluster. For cost saving purpose, you might stop/terminate it from time to time and the public IP address will change. Your developers have limited access to AWS console and they only would like to know the IP of the EC2 instance.

In this case, you can register a subdomain name for the EC2 instance and make the A record update automatically following the steps below.

## Prerequisites

1. Terraform installed for stack deployment https://learn.hashicorp.com/tutorials/terraform/install-cli

2. A user with proper privilleges is prepared with AK and SK for terraform

## Resources to Be Created in the Demo

1. VPC stacks - including internetGW, subnet(s), security group
2. IAM role/policy/profile
3. EC2 instance for testing

## Run through the demo

1. Setup a "admin" user's AK SK in the environment as `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and maintain an enrivonment value for the to be deployed region e.g. `export AWS_DEFAULT_REGION=ap-southeast-1` for Singapore Region.

``` bash
# prepare admin AK/SK
export AWS_ACCESS_KEY_ID=AdminAK
export AWS_SECRET_ACCESS_KEY=AdminSK
export AWS_DEFAULT_REGION=ap-southeast-1
```

2. Some Variables to Tweak

- Terraform Setup

  `backend "s3"` bucket name and parh are required to change.

  ***NOTE*** Terraform Lock is not implemented in the demo. If you would like to run it within a team, a lock concept should be introduced. For running terraform in AWS, you can use DynamoDB for locks.

- Check values in `variables.tf` and update them according to your own setup

- Check user_data section in ec2 resource definition and adapt to your own solution

3. Run terraform

``` bash
cd tf
terraform init
terraform apply --auto-approve

# for wipe out the complete stack, run the command below
# terraform destroy --auto-approve
```

4. Verify the Result

- Run `terraform show` to find the new IP address assigned to the EC2 instance

- Verify if this value has been updated on Route53 hosted zone record.

## Sth. To Highlight/Lowlight

Below is my script for updating the record. I am not an expert on shell scripting, so I believe you can make it more decent.

``` bash
aws s3 cp s3://yagr-demo-sg/route53-demo/upsert.json /tmp/upsert.json

publicIP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

regexstring='s/(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}/hello/gm;t;d'

sed -E ${regexstring/hello/"$publicIP"} <<< `cat /tmp/upsert.json` > /tmp/upsert.json

echo '' >> /tmp/upsert.json

aws route53 change-resource-record-sets --hosted-zone-id Z00378711D58PVI3H5ZE7 --change-batch file:///tmp/upsert.json
```

And many thanks to https://regex101.com/ and https://ihateregex.io/expr/ip/, who helped me on finding correct regex format to use.

