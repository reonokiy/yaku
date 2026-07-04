terraform {
  cloud {
    organization = "reonokiy"

    workspaces {
      name = "yaku-prod"
    }
  }
}
