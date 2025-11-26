terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

provider "oci" {
  # Use OCI CLI config file for authentication
  # This requires ~/.oci/config to be properly configured
  config_file_path = "~/.oci/config"
  profile          = "DEFAULT"
}
