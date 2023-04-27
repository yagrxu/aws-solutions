
# Topic

## Issues

1. IPs/Security cannot be obtaind from Cloud9 via terraform - which means we cannot automatically allow network access in terraform from EMR cluster
2. IAM cannot get assumed_role for federated login (variable is required)
3. In case core is small, update values in `/etc/hadoop/conf`

Core Instance should be at least xlarge to avoid memory insufficient problem.

## Cluster Configuration

find configurations in data/cluster-configurations.json for reference