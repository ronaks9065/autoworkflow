#!/bin/bash
 
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

echo "Latest release tag for $repository: $latest_release"

images=(
  "ghcr.io/sovity/edc-ce:$latest_release"
  "ghcr.io/sovity/edc-ui:$latest_release"
)

echo "Docker images to pull:"
echo "${images[@]}"

# Pull the Docker images
for image in "${images[@]}"; do
  echo "Pulling image: $image"
  docker pull "$image"
done

docker images

echo "All Docker images have been pulled."
