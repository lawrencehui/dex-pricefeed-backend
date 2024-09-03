#!/bin/bash

# Define the ECR repository URL
ECR_URL="058264122363.dkr.ecr.eu-west-2.amazonaws.com/trex/terraform/backend"

# Loop through all subdirectories in the 'services' folder
for dir in ../services/*; do
    # Skip if not a directory or if the directory is 'shared'
    if [[ -d "$dir" && "$(basename "$dir")" != "shared" ]]; then
        # Extract the directory name
        service_name=$(basename "$dir")

        # Define Docker image name
        image_name="trex/terraform/backend/$service_name"
        echo "Building image for $image_name"

        # Build, tag, and push the Docker image
        docker build -t $image_name $dir
        docker tag $image_name:latest $ECR_URL/$service_name:latest
        docker push $ECR_URL/$service_name:latest

        # Print status
        echo "Successfully built and pushed $ECR_URL/$service_name:latest"
    fi
done