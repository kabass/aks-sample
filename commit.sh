#!/bin/sh

if [[ $1 ]] then;
  echo "please specify the commit message and retry"
git status
git add .
git commit -m $1
git pull
git status
git commit -m "merge"
git push
