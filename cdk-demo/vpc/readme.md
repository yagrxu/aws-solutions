# How to

Follow the instructions below to test your first cdk app with code whisperer

## Init App

```shell
mkdir src
# the command below must be triggered under an empty directory
cdk init app --language typescript

npm run build
```

## Add VPC by Using Code Whisperer

Add new VPC with comments below

```typescript
// create a new vpc
```

If no suggestion, then add a `new` in code. A autocompletion similar to the code below will show up.

`new cdk.aws_ec2.Vpc(this, 'Vpc', {`



Complete the code

```typescript
new cdk.aws_ec2.Vpc(this, 'Vpc', {
	
})
```

New hints will show up -> `natGateways: 0,`, simply add it and another configuration hint will come `subnetConfiguration:[`

The code would look like the one below

```typescript
    // create a new vpc 
    new cdk.aws_ec2.Vpc(this, 'Vpc', {
      natGateways: 0,
      subnetConfiguration: [
      ]
    });
```



We all know that VPC should always come with some subnets, add a comment to ask Code Whisperer

```typescript
    // create a new vpc 
    new cdk.aws_ec2.Vpc(this, 'Vpc', {
      natGateways: 0,
      subnetConfiguration: [
        // create a subnet
      ]
    });
```

Then keep following the suggestions from Code Whisperer to finish the code as the one below

```typescript
    new cdk.aws_ec2.Vpc(this, 'Vpc', {
      natGateways: 0,
      subnetConfiguration: [
        // create a subnet
        {
          cidrMask: 24,
          name: 'public',
          subnetType: cdk.aws_ec2.SubnetType.PUBLIC
        }
      ]

    });
```



So far, I have no idea if it works at all.

Let's test it



## Test It

```
cdk synth
 
cdk deploy
```

You should see the output and it will be deployed.

## Destroy All

```
cdk destroy
```

