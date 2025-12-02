# Module: network

Purpose
- Creates a Virtual Cloud Network (VCN) and an Internet Gateway in OCI.

Inputs
- `compartment_id` (required): OCID of the compartment.
- `vcn_cidr` (optional): CIDR block for the VCN (default: `10.0.0.0/16`).
- `display_name` (optional): Display name prefix for created resources.

Outputs
- `vcn_id`: OCID of the created VCN.
- `igw_id`: OCID of the created Internet Gateway.

Example (from inside this module `examples/simple`):
```
module "network" {
  source = "../.."
  compartment_id = var.compartment_id
  vcn_cidr = "10.2.0.0/16"
  display_name = "example-vcn"
}
```
