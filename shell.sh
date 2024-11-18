#!/bin/bash

git clone https://github.com/ronaks9065/mirror-edc-ce-repo.git
cd mirror-edc-ce-repo

# fetch latest tag from repo
latest_tag=$(git tag --sort=version:refname | tail -n 1)
echo "Latest tag: $latest_tag"

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
 
