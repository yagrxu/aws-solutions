# Terraform to Setup EKS for X-Ray


## Prerequisites

1. Terraform installed for stack deployment https://learn.hashicorp.com/tutorials/terraform/install-cli

2. A user with proper privilleges is prepared with AK and SK for terraform run

3. Configure environment values for terraform aws provider

``` bash
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_REGION="us-west-2"
```

4. Change S3 backend location

```shell
# apply your own configuration for this setup in versions.tf

backend "s3" {
    bucket = "yagr-tfstate-log-us"
    key    = "aws-solutions/xray-demo"
    region = "us-east-1"
  }
```



## Terraform Run

You can apply the script below to setup EKS cluster for the demo.

``` bash
terraform init
terraform apply --auto-approve
```

## Terraform Cleanup

``` bash
terraform destroy --auto-approve
```
