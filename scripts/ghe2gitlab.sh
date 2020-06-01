#!/bin/bash

# This script migrates repositories from GitHub Enterprise to Gitlab.

GITHUB_URL=github.example.com
GITHUB_ADMIN_USER=admin
GITHUB_ADMIN_TOKEN=<token>
GITLAB_URL=gitlab.example.com
GITLAB_ADMIN_USER=admin
GITLAB_ADMIN_TOKEN=<token>

WORKDIR="ghe2gitlab"
if [[ ! -d "$WORKDIR" ]]; then mkdir "$WORKDIR"; fi
cd "$WORKDIR"

# get list of users
GITHUB_USERS=($(curl -fsSL "https://$GITHUB_URL/api/v3/users?access_token=$GITHUB_ADMIN_TOKEN" | jq -r .[].login))
# for each user
for GITHUB_USER in ${GITHUB_USERS[@]}; do
  # get list of project names
  PROJECT_NAMES=($(curl -fsSL "https://$GITHUB_URL/api/v3/users/$GITHUB_USER/repos?access_token=$GITHUB_ADMIN_TOKEN" | jq -r .[].name))
  # for each project
  for PROJECT_NAME in ${PROJECT_NAMES[@]}; do
    # for each project and project.wiki
    PROJECTS=("${PROJECT_NAME}" "${PROJECT_NAME}.wiki")
    for PROJECT in ${PROJECTS[@]}; do
      # check if the project exists in gitlab
      EXISTING_PROJECT=$(curl -fsSL -L -H "PRIVATE-TOKEN: $GITLAB_ADMIN_TOKEN" -X GET --data "search=$PROJECT" https://$GITLAB_URL/api/v4/projects | jq -r .[0].path_with_namespace)
      if [[ "$EXISTING_PROJECT" != "$GITLAB_ORG/$PROJECT" ]]; then
        # clone the project
        git clone "https://$GITHUB_URL/$GITHUB_USER/$PROJECT"
        if [[ -d "$PROJECT" ]]; then
          cd "$PROJECT"
          # TODO: create the user on gitlab if they don't exist
          GITLAB_USER=$GITHUB_USER
          # add the gitlab remote
          git remote add $GITLAB_URL "https://$GITLAB_URL/$GITLAB_USER/$PROJECT"
          # push to gitlab
          git push $GITLAB_URL
          # remove repository
          cd ..
          rm -rf $PROJECT
        fi
      fi
    done
  done
done

# get list of orgs
GITHUB_ORGS=($(curl -fsSL "https://$GITHUB_URL/api/v3/organizations?access_token=$GITHUB_ADMIN_TOKEN" | jq -r .[].login))
# for each org
for GITHUB_ORG in ${GITHUB_ORGS[@]}; do
  # get list of project names
  PROJECT_NAMES=($(curl -fsSL "https://$GITHUB_URL/api/v3/orgs/$GITHUB_ORG/repos?access_token=$GITHUB_ADMIN_TOKEN" | jq -r .[].name))
  # for each project
  for PROJECT_NAME in ${PROJECT_NAMES[@]}; do
    # for each project and project.wiki
    PROJECTS=("${PROJECT_NAME}" "${PROJECT_NAME}.wiki")
    for PROJECT in ${PROJECTS[@]}; do
      # check if the project exists in gitlab
      EXISTING_PROJECT=$(curl -fsSL -L -H "PRIVATE-TOKEN: $GITLAB_ADMIN_TOKEN" -X GET --data "search=$PROJECT" https://$GITLAB_URL/api/v4/projects | jq -r .[0].path_with_namespace)
      if [[ "$EXISTING_PROJECT" != "$GITLAB_ORG/$PROJECT" ]]; then
        # clone the project
        git clone "https://$GITHUB_URL/$GITHUB_ORG/$PROJECT"
        if [[ -d "$PROJECT" ]]; then
          cd $PROJECT
          # check if the org exists on gitlab
          GITLAB_ORG=$GITHUB_ORG
          RESULT=$(curl -fsSL -L -H "PRIVATE-TOKEN: $GITLAB_ADMIN_TOKEN" -X GET --data "search=$GITLAB_ORG" https://$GITLAB_URL/api/v4/groups | jq -r .[0].path)
          if [[ "$RESULT" != "$GITLAB_ORG"]]; then
            # create the org on gitlab
            curl -L -H "PRIVATE-TOKEN: $GITLAB_ADMIN_TOKEN" -X POST --data "name=$GITLAB_ORG&path=$GITLAB_ORG&description=$GITLAB_ORG" https://$GITLAB_URL/api/v4/groups
          fi
          # add the gitlab remote
          git remote add $GITLAB_URL "https://$GITLAB_URL/$GITLAB_ORG/$PROJECT"
          # push to gitlab
          git push $GITLAB_URL
          # remove repository
          cd ..
          rm -rf $PROJECT
        fi
      fi
    done
  done
done

cd ..
rm $WORKDIR