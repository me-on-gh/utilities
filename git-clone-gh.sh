#!/bin/bash

# Attempt to get GitHub username from Git configuration
GIT_USERNAME=$(git config github.user)

if [ -z "$GIT_USERNAME" ]; then
    # If not found, prompt the user for the GitHub username
    read -p "Enter your GitHub username (or email): " USERNAME
    git config --global github.user "$USERNAME"
else
    # If found, display the GitHub username
    echo "GitHub username found: $GIT_USERNAME"
    read -p "Is this the correct username? (y/n): " response
    case "$response" in
        [yY])
            USERNAME=$GIT_USERNAME
            ;;
        *)
            read -p "Enter your GitHub username (or email): " USERNAME
            git config --global github.user "$USERNAME"
            ;;
    esac
fi

# Prompt for GitHub API token
read -s -p "Enter your GitHub API token: " TOKEN
echo # Move to a new line after the token input

# Fetch repositories using the GitHub API and extract names with owners
repo_response=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/user/repos?per_page=1000")

# Extract repository names without jq
repo_names=()
while IFS= read -r line; do
    if [[ "$line" =~ "full_name" ]]; then
        repo_name=$(echo "$line" | cut -d'"' -f4)
        repo_names+=("$repo_name")
    fi
done <<< "$repo_response"

# Display menu for repository selection
PS3="Select repositories to clone (use commas for multiple, 'q' to quit): "
select repo_choice in "All" "${repo_names[@]}" "Quit"; do
    case $repo_choice in
        "Quit")
            echo "Exiting the script."
            exit 0
            ;;
        *)
            # If "All" is selected, clone all repositories
            if [ "$repo_choice" = "All" ]; then
                selected_repos=("${repo_names[@]}")
            else
                # Split selected repositories by commas
                IFS=',' read -ra selected_repos <<< "$repo_choice"
            fi

            # Ask for destination directory
            read -p "Enter the destination directory (default is current directory): " destination
            destination=${destination:-.}

            # Clone the selected repositories
            for repo_name in "${selected_repos[@]}"; do
                repo_url="git@github.com:$repo_name.git"
                destination_path="$destination/$(basename $repo_name)"
                echo "Cloning $repo_url to $destination_path"
                git clone "$repo_url" "$destination_path"
            done

            echo "Clone completed!"
            exit 0
            ;;
    esac
done
