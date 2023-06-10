import boto3

ssm_client = boto3.client('ssm')

response = ssm_client.get_parameter(Name='demo-politicians-id')
print(response['Parameter']['Value'])