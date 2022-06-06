# /bin/bash
# export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
# export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=ap-southeast-1


export TF_VAR_access_key_id=$AWS_ACCESS_KEY_ID
export TF_VAR_secret_access_key=$AWS_SECRET_ACCESS_KEY

export TF_VAR_ec2_tag_key=StopMonitor
export TF_VAR_ec2_tag_value=yes