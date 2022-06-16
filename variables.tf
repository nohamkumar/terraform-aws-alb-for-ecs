#-----
#FOR S3 BUCKET
#-----

variable "random_string" {
  description = "Creates 3 digit random number for S3 bucket name suffix if enabled. Default = false."
  default     = "false"
}

variable "log_bucket_force_destroy" {
  description = "Delete all objects from the bucket so that the bucket can be destroyed without error (e.g. `true` or `false`)"
  type        = bool
  default     = false
}
#-----
#FOR ALB
#-----

variable "internal" {
  description = "is ALB internal: true/false, default internal = false"
  default     = "false"
}

variable "vpc_id" {
  description = "vpc_id"
  type        = string
}

variable "subnets" {
  description = <<-EOF
  "A list of private subnet IDs to attach to the LB if it is INTERNAL.
  OR list of public subnet IDs to attach to the LB if it is NOT internal."
  EOF
  type        = list(string)
}

#----------------
# USED IN LB SG AND LB LISTENERS
#----------------

variable "http_listener_enabled" {
  description = "Create http listener: true or false. Default = false"
  default     = false
}

variable "http_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the Load Balancer through HTTP"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "https_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the Load Balancer through HTTPS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssl_policy" {
  description = "The name of the SSL Policy for the listener. . Required if var.https_ports is set."
  type        = string
  default     = null
}

variable "default_certificate_arn" {
  description = "The ARN of the default SSL server certificate."
  type        = string
  default     = null
}

variable "additional_security_groups" {
  description = "A list of security group IDs to assign to the LB."
  type        = list(string)
  default     = []
}


#------
#TARGET GROUPS USE
#------

variable "target_group_port" {
  description = "The target group port"
  type        = number
  default     = 80
}

variable "target_group_health_check_path" {
  description = "The destination for the health check request."
  type        = string
  default     = "/"
}

variable "target_group_health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, \"200,202\") or a range of values (for example, \"200-299\"). Default = 200."
  type        = string
  default     = "200"
}
