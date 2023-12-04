#!/bin/bash

directory_name=$(basename "$PWD")
git_username=$(git config github.user)

github_repo_url="https://github.com/${git_username}/${directory_name}.git"

git init
git remote add origin "${github_repo_url}"
git add .
git commit -m "Initial commit"
git push -u origin master
