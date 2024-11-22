#!/bin/bash
 
git clone https://github.com/sovity/edc-ce.git
cd edc-ce

# Extract Docker images from the .env file
images=$(grep -E 'IMAGE=' .env | cut -d '=' -f2)
echo "Docker images:"
echo "$images"

# Pull the Docker images
for image in $images; do
  echo "Pulling image: $image"
  docker pull "$image"
done

docker images

echo "All Docker images have been pulled."

# Define your ECR repository details
ecr_registry="public.ecr.aws/d1w2v6r1"

# Login to AWS ECR
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ecr_registry
 
# Loop through each image and push to ECR
for image in $images; do
  echo "Processing image: $image"
  
  # Extract the image name and tag (e.g., 'image:tag')
  image_name=$(echo "$image" | cut -d ':' -f1)
  image_tag=$(echo "$image" | cut -d ':' -f2)
  
  # If no tag is specified, default to 'latest'
  image_tag=${image_tag:-latest}
  
  # Determine the appropriate ECR repository based on the image name
  case "$image_name" in
    "ghcr.io/sovity/edc-dev")
      ecr_repository="edc"
      ;;
    "ghcr.io/sovity/test-backend")
      ecr_repository="test-backend"
      ;;
    "ghcr.io/sovity/edc-ui")
      ecr_repository="edc-ui"
      ;;
    *)
      echo "Unknown image: $image_name, skipping"
      continue
      ;;
  esac

  # Construct the ECR image name
  ecr_image="public.ecr.aws/d1w2v6r1/$ecr_repository:$image_tag"
  
  # Tag the image for ECR
  docker tag "$image" "$ecr_image"
  
  # Push the image to ECR
  docker push "$ecr_image"
done

echo "All images have been pushed to ECR."
