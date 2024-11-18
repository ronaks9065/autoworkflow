#!/bin/bash
 
# Mirror clone the source repository
git clone --mirror https://github.com/sovity/edc-ce.git
cd edc-ce.git

# Fetch the latest tag
latest_tag=$(git tag --sort=version:refname | tail -n 1)
echo "Latest tag: $latest_tag"

# Push the latest tag to the destination repository
git fetch origin tag "$latest_tag"
git push https://github.com/ronaks9065/mirror-edc-ce-repo.git main "refs/tags/$latest_tag"
git push https://ronaks9065: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@github.com/ronaks9065/mirror-edc-ce-repo.git main "refs/tags/$latest_tag"

# Clone the destination repository
cd ..
git clone https://github.com/ronaks9065/mirror-edc-ce-repo.git
cd mirror-edc-ce-repo
