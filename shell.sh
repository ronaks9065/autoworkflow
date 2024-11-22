#!/bin/bash

# Clone the repository and navigate to it
git clone https://github.com/sovity/edc-ce.git
cd edc-ce

# Define the repository for which you want to fetch the latest release tag
repository="sovity/edc-ce"

# Fetch the latest release tag using the GitHub API
latest_release=$(curl -s "https://api.github.com/repos/$repository/releases/latest" | jq -r '.tag_name')

# Check if the latest release was fetched successfully
if [ -z "$latest_release" ] || [ "$latest_release" == "null" ]; then
  echo "Failed to fetch the latest release tag from the GitHub API."
  exit 1
fi

# Remove the 'v' prefix if it exists
latest_release=${latest_release#v}

echo "Latest release tag for $repository: $latest_release"

# Define Docker images to pull
images=(
  "ghcr.io/sovity/edc-ce:$latest_release"
)

echo "Docker images to pull:"
echo "${images[@]}"

# Pull the Docker images
for image in "${images[@]}"; do
  echo "Pulling image: $image"
  docker pull "$image"
done

# ECR repository details
ecr_registry="public.ecr.aws/z8l4a2l1"

# Login to AWS ECR
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ecr_registry"

# Push images to ECR
for image in "${images[@]}"; do
  echo "Processing image: $image"
  
  # Extract image name and tag
  image_name=$(echo "$image" | cut -d ':' -f1)
  image_tag=$(echo "$image" | cut -d ':' -f2)
  
  # Determine the ECR repository based on the image name
  case "$image_name" in
    "ghcr.io/sovity/edc-ce")
      ecr_repository="edc"
      ;;
    *)
      echo "Unknown image: $image_name, skipping"
      continue
      ;;
  esac

  # Construct the ECR image name
  ecr_image="$ecr_registry/$ecr_repository:$image_tag"

  # Tag and push the image
  docker tag "$image" "$ecr_image"
  docker push "$ecr_image"
done

echo "All images have been pushed to ECR."
