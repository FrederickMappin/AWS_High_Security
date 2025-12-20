# Bioinformatics pipeline on AWS with High Security Standards
'
## This will be done manually for demo, for full scale we would use cloudformation to make "infrastructure as code"


## Step 0 : Prior Validation and Testing 
We will first validate and test our data pipeline using non‑sensitive test data (such as synthetic or de‑identified datasets) in an open AWS environment to ensure functionality, performance, and quality without exposing real health information, and only after those tests pass will we deploy the pipeline into a high‑security HIPAA‑compliant environment to process real protected health information.










## Step 0. IAM group & User set-up
### Goal: Set-up minimum required access to AWS services 


## Step : Set S3 buckets permission 


## Step : ECR 


## Step: CodeCommit 




## Step. Set-up VPC  
### Goal: Set-up Virtual Private Cloud without Internet Access for maximum security


```
AWS Console → VPC → Create VPC
VPC Settings:

Name: rna-seq-hipaa-vpc
IPv4 CIDR: 10.0.0.0/16
IPv6: None
Tenancy: Default
```

## Step 2.Set-up Private Subnet 
```

Subnet 1: Private Subnet AZ1
Name: rna-seq-private-subnet-az1
VPC: rna-seq-hipaa-vpc
Availability Zone: us-east-1a 
IPv6: None

Auto-assign public IPv4 address: Disabled (leave unchecked)

Subnet 2: Private Subnet AZ2
Name: rna-seq-private-subnet-az2
VPC: rna-seq-hipaa-vpc
Availability Zone: us-east-1b 
IPv6: None

Auto-assign public IPv4 address: Disabled (leave unchecked)
```


### Step 3.Set-up explicit Route Table
```
: Create Route Table
VPC → Route Tables → Create route table
Name: rna-seq-private-rt
VPC: rna-seq-hipaa-vpc
→ Create
Step 2: Verify Routes
Routes tab should show ONLY:
10.0.0.0/16 → local
(No other routes needed)
Step 3: Associate Subnets
Subnet associations tab
→ Edit subnet associations
→ Select both private subnets:
  - rna-seq-private-subnet-az1
  - rna-seq-private-subnet-az2
→ Save
```

