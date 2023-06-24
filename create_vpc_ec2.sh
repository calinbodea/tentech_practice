#!/bin/bash

# Define the CIDR range of the VPC you want to create 
MY_VPC_CIDR=10.0.0.0/25

# Define the CIDR range of public subnets you want to create
MY_PUBLIC_SUBNET_CIDR_1=10.0.0.0/27
MY_PUBLIC_SUBNET_CIDR_2=10.0.0.32/27

# Define the CIDR range of private subnets you want to create
MY_PRIVATE_SUBNET_CIDR_1=10.0.0.64/27
MY_PRIVATE_SUBNET_CIDR_2=10.0.0.96/27

# Define the AMI id for the ec2 you will create
MY_AMI_ID=ami-090e0fc566929d98b 

# Define EC2 type
EC2_TYPE=t2.micro

# Define key pair name 
KEY_PAIR_NAME=tentek

# Define number of instance you want to launch in your private subnets
NO_EC2_PRIVATE=2

# Define the number of instances you want to launch in your public subnets
NO_EC2_PUBLIC=2

# Create VPC
# aws ec2 create-vpc --cidr-block $MY_VPC_CIDR
vpc_id=$(aws ec2 create-vpc --cidr-block $MY_VPC_CIDR --query 'Vpc.VpcId' --output text) 

echo "Created VPC: $vpc_id"

# Wait 10 seconds for the creation of the VPC
sleep 10 


# Add a tag with a name for the VPC 
aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=MyVPC

# Enable DNS hostnames for the VPC
aws ec2 modify-vpc-attribute --vpc-id $vpc_id --enable-dns-hostnames

# Create a security group for the VPC
aws ec2 create-security-group --group-name MY_VPC_SG --description "allows ssh and http to my ec2" --vpc-id $vpc_id
sg_id=$(aws ec2 describe-security-groups --filters "Name=group-name, Values=MY_VPC_SG" --query "SecurityGroups[0].GroupId" --output text)

# Modify security group to allow SSH and HTTP traffic 
aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 80 --cidr 0.0.0.0/0 

# Create public subnets
subnet_id_public_1=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $MY_PUBLIC_SUBNET_CIDR_1 --availability-zone us-east-1a --query 'Subnet.SubnetId' --output text)
subnet_id_public_2=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $MY_PUBLIC_SUBNET_CIDR_2 --availability-zone us-east-1b --query 'Subnet.SubnetId' --output text)
echo "Created public subnets: $subnet_id_public_1, $subnet_id_public_2"

# Enable public IPv4 for your public subnets
aws ec2 modify-subnet-attribute --subnet-id $subnet_id_public_1 --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id $subnet_id_public_2 --map-public-ip-on-launch


# Create private subnets
subnet_id_private_1=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $MY_PRIVATE_SUBNET_CIDR_1 --availability-zone us-east-1a --query 'Subnet.SubnetId' --output text)
subnet_id_private_2=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $MY_PRIVATE_SUBNET_CIDR_2 --availability-zone us-east-1b --query 'Subnet.SubnetId' --output text)
echo "Created private subnets: $subnet_id_private_1, $subnet_id_private_2"

# Create internet gateway
gateway_id=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
echo "Created internet gateway: $gateway_id"

# Attach the internet gateway to the VPC
aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $gateway_id
echo "Attached internet gateway to VPC"

# Create public route table
public_route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id --query 'RouteTable.RouteTableId' --output text)
echo "Created public route table: $public_route_table_id"

# Associate public subnets with the public route table
aws ec2 associate-route-table --route-table-id $public_route_table_id --subnet-id $subnet_id_public_1
aws ec2 associate-route-table --route-table-id $public_route_table_id --subnet-id $subnet_id_public_2
echo "Associated public subnets with the public route table"

# Associate public route table with the interbet gateway
aws ec2 associate-route-table --route-table-id $public_route_table_id --gateway-id $gateway_id
echo "Associated public route table with internet gateway."

# Create NAT gateway
allocation_id=$(aws ec2 allocate-address --query 'AllocationId' --output text)
nat_gateway_id=$(aws ec2 create-nat-gateway --subnet-id $subnet_id_public_1 --allocation-id $allocation_id --query 'NatGateway.NatGatewayId' --output text)
echo "Created NAT gateway: $nat_gateway_id"

# Wait for the NAT gateway to be available
aws ec2 wait nat-gateway-available --nat-gateway-id $nat_gateway_id
echo "NAT gateway is available"

# Create private route table
private_route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id --query 'RouteTable.RouteTableId' --output text)
echo "Created private route table: $private_route_table_id"

# Create a route in the private route table for internet traffic through the NAT gateway
aws ec2 create-route --route-table-id $private_route_table_id --destination-cidr-block 0.0.0.0/0 --gateway-id $nat_gateway_id
echo "Created route for internet traffic through the NAT gateway"

# Associate private subnets with the private route table
aws ec2 associate-route-table --route-table-id $private_route_table_id --subnet-id $subnet_id_private_1
aws ec2 associate-route-table --route-table-id $private_route_table_id --subnet-id $subnet_id_private_2
echo "Associated private subnets with the private route table"

# Launch instances in the private subnets
for ((i=1; i<=2; i++))
do
   private_instance_id=$(aws ec2 run-instances --image-id $MY_AMI_ID --instance-type $EC2_TYPE --key-name $KEY_PAIR_NAME --security-group-ids $sg_id --subnet-id $subnet_id_private_1 --query 'Instances[0].InstanceId' --output text)
    echo "Launched instance $i: $private_instance_id"
done


# Launch instances in public subnets
for ((i=1; i<=2; i++))
do 
public_instance_id=$(aws ec2 run-instances --image-id $MY_AMI_ID --instance-type $EC2_TYPE --key-name $KEY_PAIR_NAME --security-group-ids $sg_id --subnet-id $subnet_id_public_1 --query 'Instances[0].InstanceId' --output text)
echo "Launched instance $i: $public_instance_id" 
done


