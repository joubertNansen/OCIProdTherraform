# Module: vm

Purpose
- Provisions an OCI compute instance using provided shape, image and networking.

Inputs
- `compartment_id` (required): OCID of the compartment.
- `availability_domain` (required): Availability Domain name.
- `shape` (optional): Instance shape (default `VM.Standard2.1`).
- `display_name` (required): Instance display name.
- `image_id` (required): Image OCID.
- `subnet_id` (required): Subnet OCID where the VNIC will be created.
- `assign_public_ip` (optional): Whether to assign a public IP.
- `ssh_public_key` (required): Public key for SSH access.

Outputs
- `instance_id`: OCID of the created instance.

Example (inside `examples/simple`):
```
module "vm" {
  source = "../.."
  compartment_id = var.compartment_id
  availability_domain = var.availability_domain
  display_name = "example-vm"
  image_id = "ocid1.image.oc1..example"
  subnet_id = "ocid1.subnet.oc1..example"
  ssh_public_key = file("~/.ssh/id_rsa.pub")
}
```
