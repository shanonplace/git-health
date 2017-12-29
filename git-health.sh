#!/usr/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#Make sure this folder is a valid git repo
if [ ! -d ./.git ]; then
    echo "Directory is not a valid git repo, exiting"
    exit 0
fi

echo "${bold}Checking the repo now..."

#grab the current branch
branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

#checkout develop and git latest locally
git checkout develop --quiet  && git pull --quiet

#check the merged remote branches
echo "${bold}Remote branches that have already been merged into develop...${normal}"
printf "${bold}***********************************************************************\n"
for branch in `git branch -a --merged | cut -c 3- | grep -v HEAD | grep -v "origin/develop"`; do echo -e `git show --format="%ci %cr %an" $branch | head -n 1` \\t$branch; done
printf "\n"


echo "${bold}Remote branches that have already NOT been merged into develop...${normal}"
printf "${bold}***********************************************************************\n"
for branch in `git branch -a --no-merged | cut -c 3- | grep -v HEAD`; do echo -e `git show --format="%ci %cr %an" $branch | head -n 1` \\t$branch; done

printf "\n"
printf "${bold}Branches behind develop\n"
printf "${bold}Branch Name \t Commits behind develop\n${normal}"
printf "${bold}***********************************************************************\n"
for branch in `git branch -a | grep -v HEAD | grep -v develop | cut -c 3- | sed "s/remotes//" | sed "s/\/origin/origin/"`; do
    countBehind=$(git rev-list $branch..develop --count)
    printf "$branch \t $countBehind\n"
done

printf "\n"
printf "${bold}Commits messages that don't include the Jira ticket and/or branch name\n"
printf "${bold}***********************************************************************\n"
git log --all --pretty=format:"%h, %an, %ar, %s" | grep -v "Merg" | grep -ve \w*[A-Z]\w*[A-Z]\w*
