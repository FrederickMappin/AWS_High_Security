Implementation of a Full RNA-seq pipeline on AWS

This will be done manually for demo, for full scale we would use cloudformation to make software as code 

# Step 1.VPC set-up 
AWS Console → VPC → Create VPC

```
VPC Settings:

Name: rna-seq-hipaa-vpc
IPv4 CIDR: 10.0.0.0/16
IPv6: None
Tenancy: Default
```

# Step 2. Subnet set-up
```
Subnet 1: Public Subnet AZ1
Name: rna-seq-public-subnet-az1
VPC: rna-seq-hipaa-vpc
Availability Zone: us-east-1a
IPv4 CIDR: 10.0.1.0/24
IPv6: None

After creation:
Auto-assign public IPv4 address: Enabled

Subnet 2: Public Subnet AZ2
Name: rna-seq-public-subnet-az2
VPC: rna-seq-hipaa-vpc
Availability Zone: us-east-1b
IPv4 CIDR: 10.0.2.0/24
IPv6: None

After creation:
Auto-assign public IPv4 address: Enabled

Subnet 3: Private Subnet AZ1
Name: rna-seq-private-subnet-az1
VPC: rna-seq-hipaa-vpc
Availability Zone: us-east-1a (SAME as public-az1)
IPv4 CIDR: 10.0.10.0/24
IPv6: None

Auto-assign public IPv4 address: Disabled (leave unchecked)

Subnet 4: Private Subnet AZ2
Name: rna-seq-private-subnet-az2
VPC: rna-seq-hipaa-vpc
Availability Zone: us-east-1b (SAME as public-az2)
IPv4 CIDR: 10.0.11.0/24
IPv6: None

Auto-assign public IPv4 address: Disabled (leave unchecked)
```

```
Name: rna-seq-igw

After creation:
Action: Attach to a VPC
Available VPCs: rna-seq-hipaa-vpc
```


