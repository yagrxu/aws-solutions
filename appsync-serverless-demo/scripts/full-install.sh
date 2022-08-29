cd ../tf/bootstrap
terraform init
terraform plan
terraform apply

cd ../account_setup
terraform init
terraform plan
terraform apply
export TF_VAR_access_key_id=`terraform output access_key_id` 
export TF_VAR_access_key_secret=`terraform output access_key_secret` 
export TF_VAR_role_arn=`terraform output role_arn` 

cd ../cloud_service
terraform init
terraform plan
terraform apply
# aws lambda update role binding error
aws lambda update-function-configuration --function-name demo --runtime nodejs12.x --handler index.handler --timeout 60 --memory-size 128
# aws s3 ls blog.yagrxu.me --recursive | while read line ; do echo "${line##* }"; aws s3api put-object-acl --acl public-read --bucket blog.yagrxu.me --key "${line##* }"; done
#export TF_VAR_apigw_get_id=`terraform output apigw_get_id` 
#export TF_VAR_apigw_get_stage_id=`terraform output apigw_get_stage_id` 
#export TF_VAR_domain_validation_options=`terraform output domain_validation_options` 
