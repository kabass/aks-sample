#!/bin/sh
git status
git add .
git commit -m $1
git pull
git status
git commit -m "merge"
git push
