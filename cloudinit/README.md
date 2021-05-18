### On boot, use cloud-init in configuring VMs in public cloud
####
```sh
cd aws
terraform init
terraform apply -auto-approve
terraform destroy -auto-approve
```
#### See Also
[Code Example][ref2] \
[Cloud Init Docs][ref1]

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

[ref1]: <https://cloudinit.readthedocs.io/en/latest/index.html>
[ref2]: <https://github.com/terraform-in-action/manning-code/tree/master/chapter4/complete>
