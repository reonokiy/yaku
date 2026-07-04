provider "hcloud" {
  token = var.hcloud_token
}

module "kube-hetzner" {
  source = "git::https://github.com/reonokiy/yaku.git?ref=prod"

  providers = {
    hcloud = hcloud
  }

  hcloud_token = var.hcloud_token

  cluster_name = "yaku-prod"

  ssh_public_key  = file(var.ssh_public_key_path)
  ssh_private_key = file(var.ssh_private_key_path)

  network_region = "eu-central"

  control_plane_nodepools = [
    {
      name        = "cp-nbg1"
      server_type = "cx23"
      location    = "nbg1"
      labels      = []
      taints      = []
      count       = 1
    },
    {
      name        = "cp-fsn1"
      server_type = "cx23"
      location    = "fsn1"
      labels      = []
      taints      = []
      count       = 1
    },
    {
      name        = "cp-hel1"
      server_type = "cx23"
      location    = "hel1"
      labels      = []
      taints      = []
      count       = 1
    },
  ]

  agent_nodepools = [
    {
      name        = "agent-nbg1"
      server_type = "cx33"
      location    = "nbg1"
      labels      = []
      taints      = []
      count       = 2
    },
  ]

  load_balancer_type     = "lb11"
  load_balancer_location = "nbg1"

  use_control_plane_lb = true

  firewall_ssh_source      = var.admin_cidrs
  firewall_kube_api_source = var.admin_cidrs

  create_kubeconfig    = false
  create_kustomization = false

  enable_delete_protection = {
    floating_ip   = true
    load_balancer = true
    volume        = true
  }
}

output "kubeconfig" {
  value     = module.kube-hetzner.kubeconfig
  sensitive = true
}

output "control_planes_public_ipv4" {
  value = module.kube-hetzner.control_planes_public_ipv4
}

output "agents_public_ipv4" {
  value = module.kube-hetzner.agents_public_ipv4
}

output "ingress_public_ipv4" {
  value = module.kube-hetzner.ingress_public_ipv4
}

variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "admin_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to access SSH and Kubernetes API, for example [\"1.2.3.4/32\"]."
}

variable "ssh_public_key_path" {
  type        = string
  description = "Local path to the SSH public key used for Hetzner nodes."
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Local path to the SSH private key used for provisioning nodes."
  default     = "~/.ssh/id_ed25519"
  sensitive   = true
}
