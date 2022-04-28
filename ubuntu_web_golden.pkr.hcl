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
data "amazon-ami" "ubuntu-web-east" {
  region = "us-east-2"
  filters = {
    name = "ubuntu/images/hvm-ssd/ubuntu-web-20.04-amd64-server-*"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "ubuntu-web-golden-east" {
  region         = "us-east-2"
  source_ami     = data.amazon-ami.ubuntu-web-east.id
  instance_type  = "t2.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "ubuntu_web_golden_{{timestamp}}_v${var.version}"
}

data "amazon-ami" "ubuntu-web-west" {
  region = "us-west-1"
  filters = {
    name = "ubuntu/images/hvm-ssd/ubuntu-web-20.04-amd64-server-*"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "ubuntu-web-golden-west" {
  region         = "us-west-1"
  source_ami     = data.amazon-ami.ubuntu-web-west.id
  instance_type  = "t2.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "ubuntu_web_golden_{{timestamp}}_v${var.version}"
}

build {
  name = "ubuntu_web_golden"

  sources = [
    "source.amazon-ebs.ubuntu-web-golden-east",
    "source.amazon-ebs.ubuntu-web-golden-west"
  ]

  provisioner "shell" {
    script = "setup-promtail.sh"
  }

  hcp_packer_registry {
    bucket_name = "aws_golden_web"
    description = <<EOT
      Simple http webserver to display a static webpage.
    EOT
    bucket_labels = {
      "owner"          = "jeffrey_shively"
      "os"             = "Ubuntu",
      "ubuntu-version" = "web 20.04",
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }
}
