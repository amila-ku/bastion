# Bastion

This configures an ec2 instance to be used as a bastion host.

## Technologies Used
- Packer: Build the AMI
- Ansible: configure AMI in Packer
- Goss: Test the configuration
- Terraform: Create infrstructure using AMI created with packer.

## Traffic Flow
EC2 instance is only exposed via the NLB, diredt access to EC2 is limited to VPC subnet ip range.

public internet -> NLB -> EC2 instance.


## Build AMI

### Dependencies
install packer
install ansible 
install [packer-provisioner-goss](https://github.com/YaleUniversity/packer-provisioner-goss)

export AWS credentials:

```
export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
```

Makefile provided within packer can also be used to install the dependencies


```
cd packer
make install

```

in order to build the AMI execute within the packer directory

```
make build
```

## Create Resurces in AWS

### Dependencies
[install terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

in the variables.tf file update the default value for public_subnets and vpc_id based on your vpc.

export AWS credentials:

```
export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
```

execute to resource list to be created

```
make plan
```

execute to create resources

```
make plan
```

execute to destrou resources

```
make destroy
```


Terraform will create an Autoscaling Group which creates a single instance, Network Loadbalancer, Target Groups, Security Group and Alert to monitor the active instances in target group.


# Improvements
- Add user creation with shared ssh keys in ansible.
- In order to make it possible to access other instances from bastion, use a base image which creates users and sets a ssh-key shared by the user, this way AWS keypar is does not need to be shard. User management will be handled in ansible.
- Create IAM roles and associate with bastion instance to access AWS resources.