#!/bin/bash
set -e

# Ensure clean working directory before releasing
if [ -n "$(git status --porcelain)" ]; then
  echo "Error: You have uncommitted changes. Please commit or stash them first."
  exit 1
fi

# Fetch latest tags from remote
git fetch --tags canerix-core-repo-1

# Get the latest tag (defaults to v1.0 if no tags exist)
LATEST_TAG=$(git tag -l "v*" | sort -V | tail -n 1)

if [ -z "$LATEST_TAG" ]; then
  LATEST_TAG="v1.0"
fi

# Strip the leading 'v' to perform math
VERSION="${LATEST_TAG#v}"

# Split version into Major and Minor components
MAJOR=$(echo "$VERSION" | cut -d'.' -f1)
MINOR=$(echo "$VERSION" | cut -d'.' -f2)

# Default minor to 0 if not present
MINOR=${MINOR:-0}

echo "=========================================="
echo " Current Latest Tag : $LATEST_TAG"
echo "=========================================="
echo "Select the release type:"
echo "  1) Minor Release (+0.1) -> v$MAJOR.$((MINOR + 1))"
echo "  2) Major Release (+1.0) -> v$((MAJOR + 1)).0"
echo "=========================================="
read -p "Enter choice [1 or 2]: " CHOICE

case $CHOICE in
  1)
    NEW_MINOR=$((MINOR + 1))
    NEW_TAG="v${MAJOR}.${NEW_MINOR}"
    ;;
  2)
    NEW_MAJOR=$((MAJOR + 1))
    NEW_TAG="v${NEW_MAJOR}.0"
    ;;
  *)
    echo "Invalid option. Exiting."
    exit 1
    ;;
esac

read -p "Enter release notes / description for $NEW_TAG: " RELEASE_MSG

# Create annotated tag and push
echo "Tagging repository with $NEW_TAG..."
git tag -a "$NEW_TAG" -m "$RELEASE_MSG"

echo "Pushing main branch and tag $NEW_TAG to GitHub..."
git push canerix-core-repo-1 main
git push canerix-core-repo-1 "$NEW_TAG"

echo "=========================================="
echo " Successfully pushed $NEW_TAG!"
echo " GitHub Actions will now build and attach the ISO release."
echo "=========================================="
