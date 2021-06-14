
A simple example of me learning how to use packer to create vmware virtual machines in vcenter. 

Set your vcenter, esxi, datastore, network, etc information in ubuntu-18.04.auto.pkrvars.hcl.
If you change the ssh username or password, you will need to edit it to match in preseed.cfg, 
ubuntu-18.04.auto.pkrvars.hcl  and ubuntu-18.04.pkr.hcl

Run: packer build . 

Edit script.sh to include any post build provisioning you would like to do.

Helpful Documentation and Training:

*[Learning Hashicorp Packer](https://www.linkedin.com/learning/learning-hashicorp-packer/)
*[Create and Manage Images with Packer](https://docs.joyent.com/public-cloud/api/hashicorp/packer)
*[Packer with HCL and vSphere ISO ](https://github.com/tvories/packer-vsphere-hcl)
