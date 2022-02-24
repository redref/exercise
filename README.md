# Deploy simple application

## Solutions study

For this simple example, deploying a owned full stack (which would have been k8s) is not an option. It will too complex for the work and induce too much costs for one app.

VM deployment would introduce much tooling and burden with configuring OSes.

The workload is suited to docker deployment, so we are going for cloud provided autoscaled docker deployment (FARGATE for aws).

## ECS/Fargate deployment

Configure network (VPC) with public and private subnets. Use a nat gateway to identify output traffic and be able to control and interact with it later.

Configure public LB.

Configure Fargate deployment with autoscaling based on CPU metric.

> **WARNING**: Code has not been deployed nor tested in real conditions. It would require a test AWS account access.

## Using the repo

Secret key is stored in a ciphered file.

Terraform plan can be executed with the mock_aws variable :

```
terraform plan -refresh=false -var mock_aws=true
```
