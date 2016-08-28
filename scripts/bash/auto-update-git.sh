#!/bin/bash

###################################################
#   Derek Auto-Updater                            #
###################################################
preupdate='pre-update.sh'
postupdate='post-update.sh'

# fetch changes, git stores them in FETCH_HEAD
git fetch --all

# check for remote changes in origin repository
newUpdatesAvailable=`git diff HEAD FETCH_HEAD`
if [ "$newUpdatesAvailable" != "" ]
then
        # create the fallback
        git branch fallbacks
        git checkout fallbacks

        git add .
        git add -u
        git commit -m `date "+%Y-%m-%d"`
        echo "Fallback branch created"
        if [ -f $preupdate ];
        then
            if $preupdate ; then
                echo "Pre-update succeeded"
            else
                echo "Pre-update failed... rolling back."
                git checkout master
                exit -1
            fi
        else
           echo "No pre-update routine found."
        fi
        git checkout master
        git merge FETCH_HEAD
        echo "Updates merged"
        if [ -f $postupdate ];
        then
          if $postupdate ; then
              echo "Post-update succeeded"
          else
              echo "Post-update failed... rolling back."
              git checkout master
              exit -1
          fi
        else
           echo "No post update routine found."
        fi
        echo "Deleting previous fallbacks."
else
        echo "No updates available."
        git branch --no-color --merged | grep -v \* | xargs git branch -D
fi
