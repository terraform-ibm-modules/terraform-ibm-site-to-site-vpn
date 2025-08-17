terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.80.3, < 2.0.0"
    }
  }
}

# Explicitly declaring IBM Provider to avoid unused warning which is used in submodules
# but terraform.required_providers pins the version and source in root module.
provider "ibm" {}
