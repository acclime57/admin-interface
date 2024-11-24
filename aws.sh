#!/bin/bash

# Configuration variables
BUCKET_NAME=""
REGION="us-east-1"
PROFILE="default"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    color=$1
    message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_message $RED "Error: $1 is not installed. Please install it first."
        exit 1
    fi
}

# Check required commands
check_command "aws"
check_command "jq"

# Validate input
if [ -z "$1" ]; then
    print_message $RED "Error: Please provide a bucket name as an argument"
    print_message $YELLOW "Usage: ./setup-s3-website.sh <bucket-name> [region] [profile]"
    exit 1
fi

BUCKET_NAME=$1

# Optional region parameter
if [ ! -z "$2" ]; then
    REGION=$2
fi

# Optional AWS profile parameter
if [ ! -z "$3" ]; then
    PROFILE=$3
fi

print_message $GREEN "Starting S3 static website setup..."
print_message $YELLOW "Bucket: $BUCKET_NAME"
print_message $YELLOW "Region: $REGION"
print_message $YELLOW "AWS Profile: $PROFILE"

# Create bucket
print_message $GREEN "\nCreating bucket..."
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $REGION \
    --profile $PROFILE 

# Wait for bucket to be created
sleep 5

# Enable static website hosting
print_message $GREEN "Enabling static website hosting..."
aws s3api put-bucket-website \
    --bucket $BUCKET_NAME \
    --website-configuration '{
        "IndexDocument": {"Suffix": "index.html"},
        "ErrorDocument": {"Key": "404.html"}
    }' \
    --profile $PROFILE

# Create bucket policy
print_message $GREEN "Setting bucket policy for public access..."
POLICY='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::'$BUCKET_NAME'/*"
        }
    ]
}'

# Apply bucket policy
aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --policy "$POLICY" \
    --profile $PROFILE

# Disable block public access
print_message $GREEN "Configuring public access settings..."
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false" \
    --profile $PROFILE

# Configure CORS
print_message $GREEN "Configuring CORS..."
CORS_CONFIGURATION='{
    "CORSRules": [
        {
            "AllowedHeaders": ["*"],
            "AllowedMethods": ["GET", "HEAD"],
            "AllowedOrigins": ["*"],
            "ExposeHeaders": []
        }
    ]
}'

aws s3api put-bucket-cors \
    --bucket $BUCKET_NAME \
    --cors-configuration "$CORS_CONFIGURATION" \
    --profile $PROFILE

# Get and display the website URL
WEBSITE_URL="http://$BUCKET_NAME.s3-website.us-east-1.amazonaws.com"

print_message $GREEN "\nSetup completed successfully!"
print_message $GREEN "\nWebsite URL: $WEBSITE_URL"
print_message $YELLOW "\nRemember to run your Next.js build and upload the contents of the 'out' directory:"
echo -e "npm run build"
echo -e "aws s3 sync out s3://$BUCKET_NAME --delete --profile $PROFILE"