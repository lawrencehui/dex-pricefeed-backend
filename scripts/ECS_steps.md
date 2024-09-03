# ECS batch build and deploy

#### login in to ECS

```
export AWS_PROFILE=trex-lawrencehui && aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 058264122363.dkr.ecr.eu-west-2.amazonaws.com
```
