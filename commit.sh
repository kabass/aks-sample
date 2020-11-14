#!/bin/sh

if [ "$#" -eq 0 ] ; then 
    echo "No parameter. Please enter the commit message and retry."
else
    git status
    git add .
    git commit -m $1
    git pull
    git status
    git commit -m "merge"
    git push
    
    echo "done"
fi