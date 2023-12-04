#!/bin/bash

directory_name=$(basename "$PWD")
git_email=$(git config user.email)

# Extract username from email by stripping the part between '+' and '@'
git_username=$(echo "$git_email" | awk -F'[@+]' '{print $2}')

github_repo_url="git@github.com:${git_username}/${directory_name}.git"

# GitHub token label in the keychain
github_token_label="GitHub Token"

# Attempt to get the GitHub token from the keychain
githubToken=$(security find-internet-password -a "${git_username}" -s "${github_token_label}" -w 2>/dev/null)

# If the GitHub token does not exist in the keychain, prompt the user to enter it
if [ -z "${githubToken}" ]; then
    echo "GitHub token not found in keychain. Please provide your GitHub token:"
    read -s githubToken

    # Save the GitHub token to the keychain
    security add-generic-password -a "${git_username}" -s "${github_token_label}" -w "${githubToken}" -U
fi

# Check if the directory is already a Git repository
if [ -d ".git" ]; then
    # If it's a Git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Check if the remote 'origin' already exists
        if ! git remote | grep -q "origin"; then
            # Attempt to create the remote repository on GitHub
            response=$(curl -u "${git_username}:${githubToken}" https://api.github.com/user/repos -d "{\"name\":\"${directory_name}\",\"private\":false}")
            echo "GitHub API Response: ${response}"

            # Add the remote
            git remote add origin "${github_repo_url}"
        fi

        # Perform the push, considering the default branch name
        git push -u origin HEAD:main
    else
        echo "Not a valid Git repository."
    fi
else
    # If it's not a Git repository, initialize, set username and email, add the remote, commit, and push
    git init
    git config user.name "${git_username}"
    git config user.email "${git_email}"

    # Attempt to create the remote repository on GitHub
    response=$(curl -u "${git_username}:${githubToken}" https://api.github.com/user/repos -d "{\"name\":\"${directory_name}\",\"private\":false}")
    echo "GitHub API Response: ${response}"

    # Add the remote
    git remote add origin "${github_repo_url}"

    # Perform the push, considering the default branch name
    git push -u origin HEAD:main
fi
