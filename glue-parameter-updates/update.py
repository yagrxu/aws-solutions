import boto3
import json

client = boto3.client('glue')
response = client.get_job_runs(
    JobName='demo-politicians'
)
# print(response['JobRuns'][0]['JobRunState'])

for job in response['JobRuns']:
    print(job['StartedOn'], job['JobRunState'])