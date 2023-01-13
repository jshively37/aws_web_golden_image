packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "version" {
  type    = string
  default = "1.0.0"
}

data "amazon-ami" "web-east" {
  region = "us-east-2"
  filters = {
    name                = "amzn2-ami-hvm-2.0.20210813.1-x86_64-gp2"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["amazon"]
}

source "amazon-ebs" "web-golden-east" {
  region         = "us-east-2"
  source_ami     = data.amazon-ami.web-east.id
  instance_type  = "t2.small"
  ssh_username   = "ec2-user"
  ssh_agent_auth = false
  ami_name       = "ubuntu_web_golden_{{timestamp}}_v${var.version}"
}

data "amazon-ami" "web-west" {
  region = "us-west-1"
  filters = {
    name                = "amzn2-ami-hvm-2.0.20210813.1-x86_64-gp2"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["amazon"]
}

source "amazon-ebs" "web-golden-west" {
  region         = "us-west-1"
  source_ami     = data.amazon-ami.web-west.id
  instance_type  = "t2.small"
  ssh_username   = "ec2-user"
  ssh_agent_auth = false
  ami_name       = "ubuntu_web_golden_{{timestamp}}_v${var.version}"
}

build {
  name = "ubuntu_web_golden"

  sources = [
    "source.amazon-ebs.web-golden-east",
    "source.amazon-ebs.web-golden-west"
  ]

  provisioner "shell" {
    script = "web.sh"
  }

  hcp_packer_registry {
    bucket_name = "aws-golden-web"
    description = <<EOT
      Simple http webserver to display a static webpage.
    EOT
    bucket_labels = {
      "owner"          = "jeffrey_shively"
      "os"             = "amzn2-ami-hvm"
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }
}
