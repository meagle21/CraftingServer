// VPC
resource "aws_vpc" "mc_vpc" {
  cidr_block = var.CIDR_BLOCK
}

// Security Group
resource "aws_security_group" "mc_vpc_security_group" {
    ingress {
        from_port   = var.MINECRAFT_SERVER_PORT
        to_port     = var.MINECRAFT_SERVER_PORT
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port        = var.MINECRAFT_SERVER_PORT
        to_port          = var.MINECRAFT_SERVER_PORT
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }
}

// VPC cloudwatch logs group

// VPC cloudwatch flow logs

// VPC IAM Role to generate logs and attach to vpc 

# // EC2 Instance
# resource "aws_instance" "mc_instance" {
#   ami               = data.aws_ami.MC_AMI
#   availability_zone = var.default_region
#   instance_type     = var.instance_type
# }

# // EBS Volume
# resource "aws_ebs_volume" "mc_ebs_volume" {
#   availability_zone = var.default_region
#   size              = var.storage_volume_size
# }

# // EBS Volume attachment
# resource "aws_volume_attachment" "mc_ebs_volume_attach" {
#   device_name = var.EBS_DEVICE_NAME
#   volume_id   = aws_ebs_volume.mc_ebs_volume.id
#   instance_id = aws_instance.mc_instance.id
# }

# // EBS Volume back up
# resource "aws_ebs_snapshot" "mc_ebs_volume_snapshot" {
#   volume_id = aws_ebs_volume.mc_ebs_volume.id
#   storage_tier = var.EBS_SNAPSHOT_STORAGE_TIER
# }

// Lambda
resource "aws_lambda_function" "vpc_logs_monitoring_lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = var.LAMBDA_FUNCTION_NAME
  role          = aws_iam_role.mc_vpc_monitoring_lambda.arn
  handler       = var.LAMBDA_FUNCTION_HANDLER_NAME
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime = var.LAMBDA_RUNTIME_VERSION

   environment {
    variables = {
      CLOUDWATCH_LOG_GROUP = var.CLOUDWATCH_LOG_GROUP
      LOG_STREAM_NAME = var.LOG_STREAM_NAME
    }
  }
}

// Lambda role to monitor VPC
resource "aws_iam_role" "mc_vpc_monitoring_lambda" {
  name               = "mc_vpc_monitoring_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_monitoring_policy_attachment" {
  role       = aws_iam_role.mc_vpc_monitoring_lambda.name
  policy_arn = aws_iam_policy.lambda_vpc_monitoring_policy.arn
}

// Lambda Role policy to monitor VPC logs to shut down
resource "aws_iam_policy" "lambda_vpc_monitoring_policy" {
  name        = "LambdaVPCMonitoringPolicy"
  description = "Policy that allows Lambda to read data and shut down EC2 instances"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = var.LAMBDA_PERMISSIONS
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# // Everbridge

# // Everbridge Role to Launch Lambda

# // Everbridge Role Policy to Launch Lambda