#!/bin/bash

# This helper utility facilitates the git flow process
# laid out @ https://dot-confluence.lilly.com/display/IC/Git+Flow+Process
# The usage of this utility is as follows
# 1. To initiate work on a card: gg start card-id, e.g. gg start LUSD-1234
# 2. To deploy code to dev: gg dev card-id, e.g. gg dev LUSD-1234
# 3. To deploy code to qa: gg qa card-id, e.g. gg qa LUSD-1234
# Note: This utility is a very basic helper utility. It allows quick review of PRs by
#   tagging commits with appropriate messages at checkpoints
#   It is not meant as a replacement for git command line utilities

cmd=$1
inp=$2

badargs()
{
  echo "Usage:"
  echo "gg start <jira-card#> : to start work on a card"
  echo "gg qa <jira-card#> : to prepare card for qa deployment"
  exit
}

start()
{
  card=$1
  git checkout main
  git pull
  git checkout -b feature/$card
  git commit -m "gg: githelper created feature branches for $card" --allow-empty
  git checkout -b feature/$card-qa
  git checkout feature/$card
  git push --set-upstream origin feature/$card
  git checkout feature/$card-qa
  git push --set-upstream origin feature/$card-qa
  git checkout feature/$card
  echo Following branches have now been setup for you:
  echo feature/$card: This is currently active. You should make all code changes related to you card here
  echo       Make sure to add and commit code changes
  echo feature/$card-qa: This branch should be used to reconcile conflicts with qa
  echo       Use the following command when you are done with changes to start deployment to qa
  echo          gg qa $card
  exit
}

qa()
{
  card=$1
  git checkout feature/$card
  git add . && git commit -m "gg: readying feature/$card-qa for QA deploy" --allow-empty && git push
  git checkout feature/$card-qa
  git merge feature/$card
  git pull origin qa
  git status
  echo READ THIS
  echo -----------------------------------------------------------------------------------
  echo You are now on feature/$card-qa branch
  echo Use this for conflict resolution with qa
  echo Make sure any code that you change, is done on parent feature/$card and not here
  echo Conflict resolution
  echo -----------------------------------------------------------------------------------
  echo Give preference to the qa version if you see conflicts on files you did not change
  echo Use git checkout --ours filename for quickly resolving conflicts in files/folders where you want to retain your version over the qa version
  echo Use git checkout --theirs filename if you want to retain the qa version
  echo Or resolve conflicts one by one if needed. Then add, commit and push
  echo -----------------------------------------------------------------------------------
  echo Use git status to quickly check current state
  exit
}

if [ -z $cmd ] || { [ $cmd != "start" ] && [ $cmd != "qa" ] ;}
then
  badargs
fi

if [ -z $inp ]
then
  badargs
fi

if [ $cmd == "start" ]
then
  start $inp
elif [ $cmd == "qa" ]
then
  qa $inp 
else
  echo "Usage:"
  echo "gg start <jira-card#> : to start work on a card"
  echo "gg qa <jira-card#> : to prepare card for qa deployment"
  exit
fi

exit