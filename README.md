# Purpose:
Used in ECS Fargate setup.

To create, Application Load Balancer, ALB access log setup, S3 bucket to save the access logs,
IAM policy to the S3 buckets. 

1. ALB listener = port 80, redirect to port 443.
2. ALB listener = port 443, forward to target group.

1. Security Group = egress allowed on all the ports, and protocols.
ingress rule = port 80 open (created if http_listener_enabled = true).
ingress rule = port 443 open.
                                                 

## Variable Inputs:

REQUIRED:

- namespace                     (ex: project name)
- environment                   (ex: dev/prod)
- vpc_id                        (ex: module.network.vpc_id)
- subnets                       (ex: module.network.public_subnet_ids)
- target_group_port             (ex: 80)
- default_certificate_arn       SSL cert. ARN for HTTPS.
- http_listener_enabled         Create http listener: true or false. Default = false.
                                Default = false.  

OPTIONAL:

- random_string                 Creates 3 digit random number for S3 bucket name suffix if enabled.
                                Default = false.
                                
- internal                      Is ALB internal: true/false, default = false".
                                (Pass priv. Subnet if internal).                   

- http_ingress_cidr_blocks      List of CIDR blocks allowed to access the Load Balancer through HTTP.
                                Default     = ["0.0.0.0/0"]

- https_ingress_cidr_blocks     List of CIDR blocks allowed to access the Load Balancer through HTTPS.
                                Default     = ["0.0.0.0/0"]

- ssl_policy                    The name of the SSL Policy for the listener.

- log_bucket_force_destroy      Delete all objects from the bucket so that the bucket can be
                                destroyed without error (e.g. `true` or `false`)
                                efault     = false

- target_group_health_check_path    The destination for the health check request.
                                    Default     = "/"


## Resources created:

- ALB                 [1]
- Security Groups     [1]
- S3 bucket           [1]                         
- IAM policy          [1]                                     

## Resources naming convention:

- ALB: namespace-environment-alb
    ex: sg-dev-alb
- Target Group: namespace-environment
    ex: sg-dev
- S3 bucket :
  if random_string    = true: namespace-environment-alb-logs-123
    ex: sg-dev-alb-logs-123
  if random_string    = false: namespace-environment-alb-logs
    ex: sg-dev-alb-logs
- Security Group: namespace-environment-alb
    ex: "stg-alb" or "stg-dev-alb"

# Steps to create the resources

1. Create the Network layer: (VPC, Subnet, RT, IGW,..)
    - Call the network module from your tf code.
        source: "git@github.com:studiographene/tf-modules.git//network"
    - Apply the Network module.
    for more, refer: https://github.com/studiographene/tf-modules/blob/feature/new/ecs-fargate/network/README.md
2. Call the "alb-ecs" module from your tf code.
3. Specifying the Variable Inputs along the module call.
4. Apply.

Example:

```
provider "aws" {
  region = "us-east-1"

}

module "network" {
  source      = "git@github.com:studiographene/tf-modules.git//network"
  cidr_block  = "10.0.0.0/16"
  namespace   = "sg"
  environment = "dev"
}

module "alb" {
  
  source                   = "git@github.com:studiographene/tf-modules.git//alb-ecs"
  namespace                = "stg"
  environment              = "dev"
  vpc_id                   = module.network.vpc_id
  subnets                  = module.network.public_subnet_ids
  log_bucket_force_destroy = true

  target_group_port        = 80
  default_certificate_arn  = "arn:::"
  http_listener_enabled    = true
}


```

3. From terminal: 

```
terraform init
```
```
terraform plan
```
```
terraform apply
```

!! You have successfully created ALB components as per your specification !!

---


##OUTPUTS

```
- alb_log_bucket_id:
  description = "ALB log S3 bucket ID"

- alb_log_bucket_arn:
  description = "ALB log S3 bucket ARN"

#----
#ALB
#----

- alb_id:
  description = "ALB ID"

- alb_arn:
  description = "ALB ARN"

- alb_dns_name
  description = "LB DNS name"

- alb_zone_id
  description = "LB zone ID"

- alb_target_group_arn:
  description = "Target Group ARN

#-----
#SECURITY GROUPS
#-----

 ecs_lb_security_group_id:
  description = "ID of Security Group attached to ECS ALB."

```