#!/bin/bash

directory_name=$(basename "$PWD")
git_email=$(git config user.email)

# Extract username from email by stripping the part between '+' and '@'
git_username=$(echo "$git_email" | awk -F'[@+]' '{print $2}')

github_repo_url="git@github.com:${git_username}/${directory_name}.git"

# Check if the directory is already a Git repository
if [ -d ".git" ]; then
    # If it's a Git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Check if the remote 'origin' already exists
        if ! git remote | grep -q "origin"; then
            git remote add origin "${github_repo_url}"
        fi

        # Create an initial commit even if there are no changes
        git add . 2>/dev/null || true
        git commit -m "Initial commit" 2>/dev/null || true

        # Perform the push
        git push -u origin master
    else
        echo "Not a valid Git repository."
    fi
else
    # If it's not a Git repository, initialize, set username and email, add the remote, commit, and push
    git init
    git config user.name "${git_username}"
    git config user.email "${git_email}"
    git remote add origin "${github_repo_url}"

    # Create an initial commit even if there are no changes
    git add . 2>/dev/null || true
    git commit -m "Initial commit" 2>/dev/null || true

    # Perform the push
    git push -u origin master
fi
