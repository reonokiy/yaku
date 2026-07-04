# Yaku production deployment

This directory is the Terraform root module for the production cluster.

## Terraform Cloud

The backend is configured in `cloud.tf`:

```hcl
organization = "reonokiy"
workspace    = "yaku-prod"
```

Set the Terraform Cloud workspace execution mode to `Local` unless you also move SSH keys and network access into remote execution. In local execution mode, HCP Terraform stores state but does not evaluate workspace variables, so Terraform variables must come from your local shell or local `.tfvars` files.

## Required variables

Set these in your local shell:

```sh
export TF_VAR_hcloud_token="..."
export TF_VAR_admin_cidrs='["1.2.3.4/32"]'
```

For the Packer snapshot build, also set:

```sh
export HCLOUD_TOKEN="..."
```

If you switch the workspace to `Remote` or `Agent` execution later, put `hcloud_token` and `admin_cidrs` in Terraform Cloud workspace variables instead and adjust the SSH key inputs so they do not depend on local `~/.ssh` files.

## First deploy

```sh
terraform login
terraform init
terraform validate
terraform plan -out prod.tfplan
terraform apply prod.tfplan
terraform output --raw kubeconfig > yaku-prod_kubeconfig.yaml
kubectl --kubeconfig yaku-prod_kubeconfig.yaml get nodes -o wide
```

The module source is pinned to the `prod` branch of `https://github.com/reonokiy/yaku`.
