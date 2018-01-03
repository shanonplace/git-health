#!/usr/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)
outfile="/c/tmp/git-health.html"

#Make sure this folder is a valid git repo
if [ ! -d ./.git ]; then
    printf "Directory is not a valid git repo, exiting"
    exit 0
fi

printf "Checking the repo now...\n"

git fetch --all --quiet

#grab the current branch
originalBranch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

#checkout develop and git latest locally
git checkout develop --quiet  && git pull --quiet

#check the merged remote branches
printf "Remote branches that have already been merged into develop.\n"
printf "*********************************************************************************************************\n"
for branch in `git branch -r --merged | cut -c 3- | grep -v HEAD | grep -v "origin/develop"`; do echo -e `git show --format="%cr %an" $branch | head -n 1` \\t$branch | sort -r; done
printf "\n"
printf "Remote branchces can deleted using 'git push origin :branchname'\n"
printf "You can the clean up your local using 'git fetch --all --prune'\n"
printf "\n"


printf "Remote branches that have already NOT been merged into develop.\n"
printf "*********************************************************************************************************\n"
for branch in `git branch -r --no-merged | cut -c 3- | grep -v HEAD | grep -v "origin/develop"`; do echo -e `git show --format="%cr %an" $branch | head -n 1` \\t$branch; done
printf "\n"
printf "If these branches are old or no longer needed then they should be deleted\n"
printf "Remote branches can deleted using 'git push origin :branchname'\n"
printf "You can the clean up your local using 'git fetch --all --prune'\n"
printf "\n"


printf "Branches behind develop\n"
printf "%-70s %-70s\n" "Branch Name" "Commits behind develop";
printf "*********************************************************************************************************\n"
for branch in `git branch -a | grep -v HEAD | grep -v develop | cut -c 3- | sed "s/remotes//" | sed "s/\/origin/origin/"`; do
    countBehind=$(git rev-list $branch..develop --count)
    printf "%-70s %-70s\n" $branch $countBehind;
done
printf "\n"
printf "These branches do not have the latest develop commits in them.  If they are still being used then they should be updated with the latest develop\n"
printf "branches can be updated using the following commands\n"
printf "git checkout develop\n"
printf "git pull\n"
printf "git checkout <branchname>\n"
printf "git pull\n"
printf "git merge develop\n"
printf "If that merged clean you can push it back to remote using\n"
printf "git push origin <branchname>\n"
printf "\n"

printf "Checking for files in the repo larger than 50M\n"
printf "*********************************************************************************************************\n"
largeFiles=$(git ls-tree -r -t -l --full-name HEAD | sort -n -r -k 4 | head -20 | awk '$4+0 > 5000000')
if [[ $largeFiles  ]]; then
    printf "$largeFiles\n"
    printf "\n"
    printf "Large binary files tend to slow down a git repo during clones and other operations\n"
    printf "Look to remove any large files that are no longer needed or see here for more information\n"
    printf "https://docs.microsoft.com/en-us/vsts/git/manage-large-files\n"
    printf "\n"
else
    printf "No files larger than 50M in the repo, Nice!\n"
fi
printf "\n"


printf "Commits messages that don't include the Jira ticket and/or branch name\n"
printf "*********************************************************************************************************\n"
git log --all --pretty=format:"%h, %an, %ar, %s" | grep -v "Merg" | grep -ve \w*[A-Z]\w*[A-Z]\w*
printf "\n"

printf "\n"
printf "Commits that don't include the Jira ticket and/or branch name make it dificult to understand the context'\n"
printf "of the commit after the commits are merged back into mainline and the feature branches are removed"
printf "\n"

#move back to the original branch
git checkout $originalBranch --quiet

printf "Done"

