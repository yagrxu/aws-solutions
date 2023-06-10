import boto3
import json

job_run_id = "hello"
gclient = boto3.client('glue')
pclient = boto3.client('ssm')

response = gclient.start_job_run(
    JobName='demo-politicians',
    Arguments={
        'starttime': 'string'
    },
)
print(response)

job_run_id = response['JobRunId']



response = pclient.put_parameter(
    Name='demo-politicians-id',
    Value=job_run_id,
    Type='String'
    )
response = pclient.put_parameter(
    Name='demo-politicians-status',
    Value='Running',
    Type='String'
    )
response = pclient.put_parameter(
    Name='demo-politicians-starttime',
    Value='14:00',
    Type='String'
    )
response = pclient.put_parameter(
    Name='demo-politicians-endtime',
    Value='15:00',
    Type='String'
    ) 