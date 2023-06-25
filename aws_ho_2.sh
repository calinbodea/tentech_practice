#!/bin/bash

echo "hold on to your pants, I don't know whats's happening here!"
sleep 10

# Define the CIDR range of the VPC you want to create
MY_VPC_CIDR=10.0.0.0/23

# Define the CIDR range of the public subnets that you want to create
MY_PUBLIC_SUBNET_CIDR_1=10.0.0.0/25
MY_PUBLIC_SUBNET_CIDR_2=10.0.0.128/25

# Define the CIDR range of the private subnets that you want to create
MY_PRIVATE_SUBNET_CIDR_1=10.0.1.0/25
MY_PRIVATE_SUBNET_CIDR_2=10.0.1.128/25 

# Define the AMI of the EC2 you want to spin up
MY_EC2_AMI_ID=ami-090e0fc566929d98b

# Define the EC2 type
EC2_TYPE=t2.micro

# DEfine key pair name
KEY_PAIR_NAME=tentek

# Create VPC in your desired CIDR range 
vpc_id=$(aws ec2 create-vpc --cidr-block $MY_VPC_CIDR --query 'Vpc.VpcId' --output text)
echo "Created VPC:$vpc_id"

# Wait for VPC to be created
sleep 10

# Create a name tag for your newly created VPC
aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=AWS_HANDS_ON_2_VPC

# Create 2 public subnets in your desired availability zones
subnet_id_public_1=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $MY_PUBLIC_SUBNET_CIDR_1 --availability-zone us-east-1a --query 'Subnet.SubnetId' --output text)
subnet_id_public_2=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $MY_PUBLIC_SUBNET_CIDR_2 --availability-zone us-east-1b --query 'Subnet.SubnetId' --output text)
echo "Created public subnets:$subnet_id_public_1 and $subnet_id_public_2" 

# Enable public IPv4 for your public subnets
aws ec2 modify-subnet-attribute --subnet-id $subnet_id_public_1 --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id $subnet_id_public_2 --map-public-ip-on-launch

# Create a name tag for your public subnets
aws ec2 create-tags --resources $subnet_id_public_1 --tags Key=Name,Value="PUBLIC_SUBNET_AZ_US_EAST_1a"
aws ec2 create-tags --resources $subnet_id_public_2 --tags Key=Name,Value="PUBLIC_SUBNET_AZ_US_EAST_1b"

# Create 2 public subnets in your desired availability zones
subnet_id_private_1=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $MY_PUBLIC_SUBNET_CIDR_1 --availability-zone us-east-1a --query 'Subnet.SubnetId' --output text)
subnet_id_private_2=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $MY_PUBLIC_SUBNET_CIDR_2 --availability-zone us-east-1b --query 'Subnet.SubnetId' --output text)

# Create a name tag for your public subnets
aws ec2 create-tags --resources $subnet_id_private_1 --tags Key=Name,Value="PRIVATE_SUBNET_AZ_US_EAST_1a"
aws ec2 create-tags --resources $subnet_id_private_2 --tags Key=Name,Value="PRIVATE_SUBNET_AZ_US_EAST_1b"

# Create Internet Gateway 
gateway_id=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
echo "Created internet gateway: $gateway_id"

# Attach the Internet Gateway to the VPC
aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $gateway_id
echo "Attached internet gateway to VPC"

# Retrieve the default route ID that was created when the VPC was created
 default_route_table_id=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$vpc_id Name=association.main,Values=true --query 'RouteTables[0].RouteTableId' --output text)

# Attach public subnets to the default route table from previous step
aws ec2 associate-route-table --route-table-id $default_route_table_id --subnet-id $subnet_id_public_1
aws ec2 associate-route-table --route-table-id $default_route_table_id --subnet-id $subnet_id_public_2
echo "Associated public subnets to the default route table."

# Create internet route to the route table the public subnets are associated to: destination 0.0.0.0/0 taarget: internet gateway
aws ec2 create-route --route-table-id $default_route_table_id --destination-cidr-block 0.0.0.0/0 --gateway-id $gateway_id

# Create private route table 
private_route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id --query 'RouteTable.RouteTableId' --output text)
echo "Created public route table: $private_route_table_id"

# Attach private subnets to the private route table
aws ec2 associate-route-table --route-table-id $private_route_table_id --subnet-id $subnet_id_private_1
aws ec2 associate-route-table --route-table-id $private_route_table_id --subnet-id $subnet_id_private_2
echo "Associated private subnets to the private route table."

# Create a security group for the VPC and get the security group ID
aws ec2 create-security-group --group-name PUBLIC_SG --description "allows ssh and http to my ec2" --vpc-id $vpc_id
sg_id=$(aws ec2 describe-security-groups --filters "Name=group-name, Values=PUBLIC_SG" --query "SecurityGroups[0].GroupId" --output text)

# Modify security group rules to allow SSh and HTTP traffic
aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 80 --cidr 0.0.0.0/0

# Spin up an EC2 in your public subnet in az us-east-1a, install apache on it and modify /var/www/html/index.html file to display "Hello World from Ec2"
public_ec2_1a_id=$(aws ec2 run-instances --image-id $MY_EC2_AMI_ID --instance-type $EC2_TYPE --key-name $KEY_PAIR_NAME --security-group-ids $sg_id --subnet-id $subnet_id_public_1 --user-data /Users/calinbodea/workspace/userdata.sh --query 'Instances[0].InstanceId' --output text)
echo "Created EC2 $public_ec2_1a_id" 

# Add a name tag to your instance
aws ec2 create-tags --resources $public_ec2_1a_id --tags Key=Name,Value="AWS_HO2_EC2_PUBLIC_1a"

# Test to see if the httpd service that was supposed to be installed from script is active
httpd_status_public_ec2_1a=$(aws ssm send-command --instance-ids $public_ec2_1a_id --document-name "AWS-RunShellScript" --parameters "commands=['systemctl is-active httpd']" --output text --query 'CommandInvocations[*].CommandPlugins[*].Output')

# Test to see if file /var/www/html/index.html has something written in it
index_html_size_public_ec2_1a=$(aws ssm send-command --instance-ids $public_ec2_1a_id --document-name "AWS-RunShellScript" --parameters "commands=['stat -c %s /var/www/html/index.html']" --output text --query 'CommandInvocations[*].CommandPlugins[*].Output')

# Check if httpd service is active and index.html is not empty
if [ "$httpd_status_public_ec2_1a" = "active" ] && [ "$index_html_size_public_ec2_1a" -gt 0 ]; then
  echo "httpd service is active and /var/www/html/index.html is not empty."
else
  echo "Go back to the drawing board!"
fi

# Modify the security group rules to stop allowing http traffic
aws ec2 revoke-security-group-ingress --group-id $sg_id --protocol tcp --port 80 --cidr 0.0.0.0/0

# Create a AMI image of you instance
custom_ami_id=$(aws ec2 create-image --instance-id  $public_ec2_1a_id --name "My_AMI" --description "My_Custom_AMI" --query 'ImageId' --output text)
echo "Created AMI of the public istance $public_ec2_1a_id: $custom_ami_id" 

# Launch ec2 in public subnet, az-1b using the custom AMI you just created and the same security group 
 public_ec2_1b_id=$(aws ec2 run-instances --image-id $custom_ami_id --instance-type $EC2_TYPE --key-name $KEY_PAIR_NAME --security-group-ids $sg_id --subnet-id $subnet_id_public_2 --query 'Instances[0].InstanceId' --output text)
echo "Created EC2 $public_ec2_1b_id"

# Add a name tag to your instance
aws ec2 create-tags --resources $public_ec2_1b_id --tags Key=Name,Value="AWS_HO2_EC2_PUBLIC_1b"

# Create a target group in your VPC
target_group_id=$(aws elbv2 create-target-group --name "AWS_HO_TG" --protocol HTTP --port 80 --vpc-id $vpc_id --query 'TargetGroups[0].TargetGroupArn' --output text)
echo "Created target group: $target_group_id"

# Attach both ec2 to your target group
aws elbv2 register-targets --target-group-arn $target_group_id --targets $public_ec2_1a_id
aws elbv2 register-targets --target-group-arn $target_group_id --targets $public_ec2_1b_id
echo "Attached instances $public_ec2_1a_id and $public_ec2_1b_id to $target_group_id"

# Create a security group for a ALB and get the security group ID
aws ec2 create-security-group --group-name ALB_SG --description "allows http to my ALB" --vpc-id $vpc_id
alb_sg_id=$(aws ec2 describe-security-groups --filters "Name=group-name, Values=ALB_SG" --query "SecurityGroups[0].GroupId" --output text)

# Modify rules to ALB sec group to allow HTTP traffic to port 80
aws ec2 authorize-security-group-ingress --group-id $alb_sg_id --protocol tcp --port 80 --cidr 0.0.0.0/

# Create a new application load balancer using both public subnets
aws elbv2 create-load-balancer --name "AWS_H02_ALB" --subnets $subnet_id_public_2 $subnet_id_public_1 --security-groups $alb_sg_id --type application
alb_id=$(aws elbv2 describe-load-balancers --names "AWS_HO2_ALB" --query 'LoadBalancers[0].LoadBalancerArn' --output text)
echo "Created ALB: $alb_id"

# Create and configure a listener for the ALB 
aws elbv2 create-listener --load-balancer-arn $alb_id --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$target_group_id

# Modify the rules for the security group you used to spin up the instances to allow HTTP port 80 traffic to ALB security group
 aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 80 --source-group $alb_sg_id

 # Wait 2 minutes for the instances to become healthy in your target group
 sleep 120

 # Get the Load Balancer DNS name and try reaching it from your browser
 alb_dns_name=$(aws elbv2 describe-load-balancers --load-balancer-arns $alb_id --query 'LoadBalancers[0].DNSName' --output text)
 echo "Load balancer DNS name is $alb_dns_name" 

 sleep 5 

 echo "Right now, copy ALB DNS name into your browser!    $alb_dns_name       "    


 

