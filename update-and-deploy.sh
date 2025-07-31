#!/bin/bash

set -e  # Exit on error

# ------------------------------
# CONFIGURATION
# ------------------------------
ECR_REPO_URL="607700977843.dkr.ecr.us-east-2.amazonaws.com/strapi-ecs-kg"
IMAGE_NAME="strapi-ecs-kg"
TERRAFORM_DIR="terraformA"
AWS_REGION="us-east-2"
ECS_CLUSTER_NAME="strapi-cluster-kg"   
ECS_SERVICE_NAME="strapi-service-kg-spot"
TAG=$(date +%Y%m%d-%H%M%S)                 # Timestamp tag for image
BRANCH="main"
# ------------------------------

echo "=== STEP 1: Building Strapi production build ==="
npm run build

echo "=== STEP 2: Building Docker image ==="
docker build -t $IMAGE_NAME:$TAG -t $IMAGE_NAME:latest .

echo "=== STEP 3: Logging in to AWS ECR ==="
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_URL

echo "=== STEP 4: Tagging and pushing Docker image ==="
docker tag $IMAGE_NAME:$TAG $ECR_REPO_URL:$TAG
docker tag $IMAGE_NAME:latest $ECR_REPO_URL:latest
docker push $ECR_REPO_URL:$TAG
docker push $ECR_REPO_URL:latest

echo "=== STEP 5: Committing Strapi changes (if any) ==="
git add src config
git commit -m "Update Strapi content types and redeploy" || echo "No changes to commit."
git push origin $BRANCH

echo "=== STEP 6: Applying Terraform (ECS redeploy) ==="
cd $TERRAFORM_DIR
terraform apply -auto-approve
cd ..

echo "=== STEP 7: Verifying ECS Service ($ECS_SERVICE_NAME) ==="
aws ecs describe-services \
  --cluster $ECS_CLUSTER_NAME \
  --services $ECS_SERVICE_NAME \
  --region $AWS_REGION \
  --query "services[0].deployments[0].status"

echo "=== DONE! Strapi has been redeployed on ECS (port 1337). ==="
