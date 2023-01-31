# Demo Work Through

### Prerequisites

1. Configure Amazon CloudWatch Cross-Account using [this Blog](https://aws.amazon.com/blogs/aws/new-amazon-cloudwatch-cross-account-observability/)
1. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
1. Install and Configure [aws cli](https://aws.amazon.com/cli/)

### Deployment Infrastructure

Change variables in `.tfvars` file

``` shell
# in account-a tf directory
# assuming BACKEND_ACCESS_KEY_ID and BACKEND_SECRET_ACCESS_KEY is the credential for the S3 backend access
terraform init -backend-config="access_key=$BACKEND_ACCESS_KEY_ID"  -backend-config="secret_key=$BACKEND_SECRET_ACCESS_KEY"
terraform apply --auto-approve -var-file="../account-a.tfvars"

# in account-b tf directory
# assuming BACKEND_ACCESS_KEY_ID and BACKEND_SECRET_ACCESS_KEY is the credential for the S3 backend access
terraform init -backend-config="access_key=$BACKEND_ACCESS_KEY_ID"  -backend-config="secret_key=$BACKEND_SECRET_ACCESS_KEY"

terraform apply --auto-approve
```



### Deploy X-Ray Collector

```yaml
apiVersion: opentelemetry.io/v1alpha1
kind: OpenTelemetryCollector
metadata:
  name: adot-collector
  namespace: observability
spec:
  serviceAccount: adot-collector
  mode: deployment
  config: |
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318       
    processors:
      batch/metrics:
        timeout: 60s         

    ## for adot addon 0.58.0 and above     
    extensions:
      sigv4auth:
        region: ap-southeast-1
        service: "aps"

    exporters:
      awsxray:
        region: ap-southeast-1

    service:
      extensions: [sigv4auth]
      pipelines:
          traces:
            receivers: [otlp]
            processors: []
            exporters: [awsxray]
          
```

 

### Deploy Demo Apps

Change account ID and aws cli profile name under `./demo-apps/caller/dockerbuild.sh` and `./demo-apps/callee/dockerbuild.sh`

```shell
	# ./demo-apps/caller
	kubectx account-b
	sh ./dockerbuild.sh
	helm upgrade -i hello ./helmchart
	
	# ./demo-apps/callee
	kubectx account-a
	sh ./dockerbuild.sh
	helm upgrade -i world ./helmchart
```



### Verify Result

You can verify result in monitoring account.

1. [Metrics] CloudWatch - go to EC2 per instance metrics, where you can find instance metrics from both monitoring account and source account
2. [Traces] X-Ray - forward port 8080 of deployment `Hello` and call the service with `curl -s http://localhost:8080/hello` If everything works, it should response with `helloworld`
3. [Logs] CloudWatch Logs - go to CloudWatch Logs and find log groups from both accounts
