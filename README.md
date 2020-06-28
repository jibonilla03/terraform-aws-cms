# Basic Terraform Help

### Requirements:

- Terraform
- Ansible
- AWS admin access

### Development Tools Used:
```shell
ansible 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/jbonilla/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.8.2 (default, Mar 13 2020, 10:14:16) [GCC 9.3.0]

terraform version
Terraform v0.12.28
+ provider.aws v2.68.0
```

Before using the terraform, we need to export `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as environment variables:

```
export AWS_ACCESS_KEY_ID="xxxxxxxxxxxxxxxx"
export AWS_SECRET_ACCESS_KEY="yyyyyyyyyyyyyyyyyyyy"
```
To Generate and show an execution plan (dry run):
```
terraform plan
```
To Builds or makes actual changes in infrastructure:
```
terraform apply
```
To inspect Terraform state or plan:
```
terraform show
```
To destroy Terraform-managed infrastructure:
```
terraform destroy
```
**Note**: Terraform stores the state of the managed infrastructure from the last time Terraform was run. Terraform uses the state to create plans and make changes to the infrastructure.

### Ansible Role after Terraform Provisioning:

Once the Terraform will create all the resources over AWS, you can use the Ansible to install the wordpress over the EC2 instance(s)

### To use the provided Role:
```local-exec
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --key-file ./secrets/key.pem -i '${self.public_ip},' site.yml
```