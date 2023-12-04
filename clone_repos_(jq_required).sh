#!/bin/bash

USERNAME="YOUR_USERNAME"
TOKEN="YOUR_TOKEN"

# Fetch repositories using the GitHub API and extract names with owners
repos_json=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/user/repos?per_page=1000")
repo_names=$(echo $repos_json | jq -r '.[].full_name')

# Display menu for repository selection
PS3="Select a repository to clone (or 'q' to quit): "
select repo_name in $repo_names "Quit"; do
    case $repo_name in
        "Quit")
            echo "Exiting the script."
            exit 0
            ;;
        *)
            echo "Selected repository: $repo_name"
            break
            ;;
    esac
done

# Ask for destination directory
read -p "Enter the destination directory (default is current directory): " destination
destination=${destination:-.}

# Clone the selected repository
repo_url="git@github.com:$repo_name.git"
destination_path="$destination/$(basename $repo_name)"

echo "Cloning $repo_url to $destination_path"
git clone $repo_url $destination_path

echo "Clone completed!"
