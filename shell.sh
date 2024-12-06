#!/bin/bash
   
# Clone the repository and navigate to it
git clone https://github.com/sovity/edc-ce.git
cd edc-ce 

# Define the repository for which you want to fetch the latest release tag
repository="sovity/edc-ce"

# Fetch the latest release tag using the GitHub API
latest_release=$(curl -s "https://api.github.com/repos/$repository/releases/latest" | jq -r '.tag_name')

# for fetching previous release
# latest_release=$(curl -s "https://api.github.com/repos/$repository/releases" | jq -r '.[8].tag_name')


# Check if the latest release was fetched successfully
if [ -z "$latest_release" ] || [ "$latest_release" == "null" ]; then
  echo "Failed to fetch the latest release tag from the GitHub API."
  exit 1
fi

# Remove the 'v' prefix if it exists
latest_release=${latest_release#v}

echo "Latest release tag for $repository: $latest_release"

# Define the Docker image to pull
image_name="ghcr.io/sovity/edc-ce"
image_tag="$latest_release"
full_image="$image_name:$image_tag"

echo "Docker image to pull: $full_image"

# Pull the Docker image
echo "Pulling image: $full_image"
docker pull "$full_image"

aws s3 ls

# # ECR repository details
# ecr_registry="public.ecr.aws/z8l4a2l1"
# ecr_repository="edc"
# ecr_image="$ecr_registry/$ecr_repository:$image_tag"

# # Login to AWS ECR
# aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ecr_registry"

# # Tag and push the image to ECR
# echo "Tagging image: $full_image as $ecr_image"
# docker tag "$full_image" "$ecr_image"

# echo "Pushing image to ECR: $ecr_image"
# docker push "$ecr_image"

# echo "Image has been successfully pushed to ECR."
