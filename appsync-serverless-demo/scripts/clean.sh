cd ./tf/account_setup
terraform init
terraform plan
terraform apply
export TF_VAR_access_key_id=`terraform output access_key_id` 
export TF_VAR_access_key_secret=`terraform output access_key_secret` 
export TF_VAR_role_arn=`terraform output role_arn` 

cd ../cloud_service
terraform init
terraform plan
terraform destroy --auto-approve

cd ../account_setup
terraform init
terraform plan
terraform destroy --auto-approve

cd ../bootastrap
terraform init
terraform plan
terraform destroy --auto-approve