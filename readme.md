# Bioinformatics pipeline on AWS with High Security Standards
'
## This will be done manually for demo, for full scale we would use cloudformation to make "infrastructure as code"


## Step 0 : Prior Validation and Testing 
We will first validate and test our data pipeline using non‑sensitive test data (such as synthetic or de‑identified datasets) in an open AWS environment to ensure functionality, performance, and quality without exposing real health information, and only after those tests pass will we deploy the pipeline into a high‑security HIPAA‑compliant environment to process real protected health information.


## Step 1: VPC Infrastructure Setup



## Set-up VPC  
### Goal: Set-up Virtual Private Cloud without Internet Access for maximum security


```
AWS Console → VPC → Create VPC
VPC Settings:

Name: rna-seq-hipaa-vpc
IPv4 CIDR: 10.0.0.0/16
IPv6: None
Tenancy: Default
```

## Set-up Private Subnet 
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
## Step: Configure Network ACLs 
VPC → Network ACLs → Create network ACL
Name: rna-seq-private-nacl
VPC: rna-seq-hipaa-vpc
→ Create
```
Configure Inbound Rules:
Rule # | Type        | Protocol | Port Range | Source      | Allow/Deny
100    | HTTPS       | TCP      | 443        | 10.0.0.0/16 | Allow
110    | Custom TCP  | TCP      | 1024-65535 | 10.0.0.0/16 | Allow (ephemeral)
*      | All traffic | All      | All        | 0.0.0.0/0   | Deny

Configure Outbound Rules:
Rule # | Type        | Protocol | Port Range | Destination | Allow/Deny
100    | HTTPS       | TCP      | 443        | 0.0.0.0/0   | Allow (VPC endpoints)
110    | Custom TCP  | TCP      | 1024-65535 | 10.0.0.0/16 | Allow (ephemeral)
*      | All traffic | All      | All        | 0.0.0.0/0   | Deny

Associate with Subnets:
→ Subnet associations tab
→ Edit subnet associations
→ Select both:
  - rna-seq-private-subnet-az1
  - rna-seq-private-subnet-az2
→ Save
```
### Set-up explicit Route Table
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


### Set-up Create Security Group

```
VPC → Security Groups → Create security group

Name: rna-seq-vpc-endpoint-sg
Description: Allow VPC resources to access VPC endpoints
VPC: rna-seq-hipaa-vpc

Inbound rules:
  Add rule →
    Type: HTTPS
    Source: Custom → 10.0.0.0/16

Outbound rules:
  Keep default (allows all outbound)

→ Create security group
```


### Deploy VPC Endpoints
```
CloudFormation → Create stack

Upload: vpc-endpoints.yaml

Parameters:
  VpcId: vpc-xxxxx
  PrivateSubnet1Id: subnet-xxxxx
  PrivateSubnet2Id: subnet-xxxxx
  RouteTableId: rtb-xxxxx
  SecurityGroupId: sg-xxxxx 

→ Create stack
```

## Step 2: IAM Setup
```
Step 1: Create Group
IAM → User groups → Create group
Name: RNASeqAdministrators
→ Create group

Step 2: Create and Attach Policy to Group
IAM → Policies → Create policy
→ JSON tab
→ Paste your JSON (with correct bucket name)
→ Next
Name: RNASeqAdministratorPolicy
Description: Full access to RNA-Seq pipeline
→ Create policy

Then:
IAM → User groups → RNASeqAdministrators
→ Permissions → Add permissions → Attach policies
→ Search: RNASeqAdministratorPolicy
☑ Select it
→ Attach policies

Step 3:  Add User  to Group

Set permissions:
☑ Add user to group
☑ RNASeqAdministrators
→ Next

```



Step 3: Service Configuration

## S3 Console → Create bucket

```
S3 Console → Create bucket

Bucket name: rnaseq-hipaa-data-bucket

Region: US East (N. Virginia) us-east-1

Block Public Access: ✓ Block all public access

Bucket Versioning: Enable

Default encryption: 
  - Server-side encryption: Enabled
  - Encryption type: SSE-S3 (AES-256)

→ Create bucket

Click into: rnaseq-hipaa-data-bucket

→ Create folder

Folder names (create each separately):
  - raw-data/
  - results/
  - logs/
  - reference/

→ Create folder (for each)

```


