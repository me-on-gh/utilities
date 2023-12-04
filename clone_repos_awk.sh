#!/bin/bash

# Prompt for GitHub username (email)
read -p "Enter your GitHub username (or email): " USERNAME

# Prompt for GitHub API token
read -s -p "Enter your GitHub API token: " TOKEN
echo # Move to a new line after the token input

# Fetch repositories using the GitHub API and extract names with owners
repo_names=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/user/repos?per_page=1000" | grep -o '"full_name": "[^"]*' | cut -d'"' -f4)

# Add "All" option to the list of repositories
all_repos="All"
repo_names="$all_repos $repo_names"

# Display menu for repository selection
PS3="Select repositories to clone (use commas for multiple, 'q' to quit): "
select repo_choice in $repo_names "Quit"; do
    case $repo_choice in
        "Quit")
            echo "Exiting the script."
            exit 0
            ;;
        *)
            # Check if "All" is selected
            if [ "$repo_choice" = "$all_repos" ]; then
                selected_repos=$repo_names
            else
                # Split selected repositories by commas
                IFS=',' read -ra selected_repos <<< "$repo_choice"
            fi

            # Ask for destination directory
            read -p "Enter the destination directory (default is current directory): " destination
            destination=${destination:-.}

            # Clone the selected repositories
            for repo_name in ${selected_repos[@]}; do
                repo_url="git@github.com:$repo_name.git"
                destination_path="$destination/$(basename $repo_name)"
                echo "Cloning $repo_url to $destination_path"
                git clone $repo_url $destination_path
            done

            echo "Clone completed!"
            exit 0
            ;;
    esac
done