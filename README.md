Terraform AWS Modules
---------------------

it creates fully operational AWS VPC infrastructure
- subnets
- routeing tables
- igw

it creates EC2 and RDS instances 
- security key
- security group
- subnet group

It creates the Elastic Load Balancer and add the EC2 instance(s) 
It adds Route53 entry for this site and add the ELB alias to it. 


### Terraform AWS Modules Tasks:

- Create 1 x VPC with 4 x VPC subnets(2 x public and 2 x private) in differrent AZ zones inside the AWS region
- Create the AWS key pair with the provided public key
- Create 1 x security group for each(SSH,Webservers,RDS and ELB)
- Provision 2 x EC2 instances in 2 different public AZ
- Provision 1 x RDS instance in private subnets
- Launch and configure public facing VPC ELB (cross_az_load_balancing) and attach VPC subnets
- Register EC2 instances on ELB
- Take the ELB dnsname and register/create dns entry in Route53

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