# Create an S3 bucket 
# TODO: lifecycle policy
# TODO: storage class (what's the cheapest?)
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    application = "minecraft"
  }
}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "my-tfstate-files"
    key    = "networking.prod.tfstate"
    region = "us-west-2"
  }
}

# Create a security group to allow Minecraft traffic and management over SSH
resource "aws_security_group" "minecraft_server" {
  name        = "${var.env_prefix}minecraft-server"
  description = "Allow minecraft traffic and limited SSH"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  tags = {
    Name        = "minecraft-server"
    application = "minecraft"
  }
}

# Minecraft uses port 25565
resource "aws_security_group_rule" "allow_minecraft_port" {
  type      = "ingress"
  from_port = 25565
  to_port   = 25565
  protocol  = "tcp"
  description = "Minecraft port"

  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.minecraft_server.id
}

resource "aws_security_group_rule" "allow_dynmap_port" {
  type      = "ingress"
  from_port = 8123
  to_port   = 8123
  protocol  = "tcp"
  description = "Dynmap port"

  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.minecraft_server.id
}

# Allow SSH from a specific list of IPs
resource "aws_security_group_rule" "allow_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  description = "Syd Sisco IP"

  cidr_blocks = [
    "64.46.11.141/32", #Syd Sisco IP
    "72.39.164.110/32" #Syd Sisco Mom's IP
  ]

  security_group_id = aws_security_group.minecraft_server.id
}

# Allow all outbound traffic
resource "aws_security_group_rule" "allow_all_outbound" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "all"

  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.minecraft_server.id
}

# Policy Document to attach to IAM Role to allow EC2 instances to assume the role
data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM Role for the minecraft server instance
resource "aws_iam_role" "minecraft_server" {
  name               = "${var.env_prefix}minecraft_server_role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

  tags = {
    application = "minecraft"
  }
}

# EC2 instances use an IAM Instance Profile to assume an IAM role
resource "aws_iam_instance_profile" "minecraft_server" {
  name = aws_iam_role.minecraft_server.name
  role = aws_iam_role.minecraft_server.name
}

# Policy document to allow basic read and write operations
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.bucket.id}",
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*",
    ]
  }
}

# Policy to attach the bucket policy document to
resource "aws_iam_policy" "bucket_policy" {
  name   = "${var.env_prefix}minecraft_bucket_policy"
  policy = data.aws_iam_policy_document.bucket_policy.json
}

# Attach the bucket policy to the IAM Role
resource "aws_iam_role_policy_attachment" "bucket_policy" {
  role       = aws_iam_role.minecraft_server.name
  policy_arn = aws_iam_policy.bucket_policy.arn
}

# Attach the Cloudwatch Agent policy to the IAM Role
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  role       = aws_iam_role.minecraft_server.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Find the latest Ubuntu image
data "aws_ami" "ubuntu_18_latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# The EC2 instance that will serve as the Minecraft server
resource "aws_instance" "server" {
  ami                    = data.aws_ami.ubuntu_18_latest.id
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.minecraft_server.id]
  iam_instance_profile   = aws_iam_instance_profile.minecraft_server.name
  subnet_id = data.terraform_remote_state.networking.outputs.public_subnet_ids[0] # TODO: gotta be a better way than [0]
  user_data = templatefile("${path.module}/files/userdata.sh.tmpl", {bucket_name = var.bucket_name})
  associate_public_ip_address = true

  tags = {
    Name        = "${var.env_prefix}minecraft-server"
    application = "minecraft"
  }
}

# # generate an Elastic IP (static ip) and associate it with the EC2 instance
# resource "aws_eip" "ip" {
#   instance = aws_instance.server.id
#   vpc      = true

#   tags = {
#     application = "minecraft"
#   }
# }

# Create a DNS record so friends can find the server :)
resource "aws_route53_record" "www" {
  zone_id = "Z33X8FW1ZB287X"
  name    = "${var.env_prefix}minecraft"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.server.public_ip]
}
