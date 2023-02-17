#!/bin/bash
set -e

#Constance
OUTPUT_PATH=".output"

#Variable information from $GITHUB_EVENT_PATH
event_json=$(cat $GITHUB_EVENT_PATH)

USER=$(echo $event_json | jq '.pull_request.user.login' | sed 's/"//g') #User who created hotfix-PR
HEAD_BRANCH=$(echo $event_json | jq '.pull_request.head.ref' | sed 's/"//g') #Branch to merge into develop
REPO_FULLNAME=$(echo $event_json | jq '.repository.full_name' | sed 's/"//g') #Username + repositoryname
PR_NUMBER=$(echo $event_json | jq '.number' | sed 's/"//g') #Number of hotfix-PR
newPR_NUMBER=$((PR_NUMBER + 1)) #Number of PR into develop
MAIN_PR=$(echo $event_json | jq '.pull_request.html_url' | sed 's/"//g') #URL of hotfix-PR
TARGET_PR="https://github.com/$REPO_FULLNAME/pull/$newPR_NUMBER" #URL of PR into develop

#Microsoft Teams webhook
function webhook ()
{
  WEBHOOK_URL=${MSTEAMS_WH} #From workflow.yml
  TITLE=$1
  COLOR="d7000b" #red
  TEXT=$2
  MESSAGE=$( echo ${TEXT} | sed 's/"/\"/g' | sed "s/'/\'/g" | sed 's/*/ /g' ) # " --> \", ' --> \', * --> space
  TITLE=$( echo ${TITLE} | sed 's/"/\"/g' | sed "s/'/\'/g" | sed 's/*/ /g' ) # " --> \", ' --> \', * --> space
  JSON="{\"title\": \"${TITLE}\", \"themeColor\": \"${COLOR}\", \"text\": \"${MESSAGE}\" }" #.json for webhook
  curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}" #send .json to webhook
}

#Create PR
function create_pr ()
{
  TITLE="hotfix auto merged by $USER" #Title for PR
  RESPONSE_CODE=$(curl \
    -o $OUTPUT_PATH -s -w "%{http_code}\n" \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/$REPO_FULLNAME/pulls \
    --data "{\"title\":\"$TITLE\",\"body\":\"Automated PR by gitflow-automation\",\"head\":\"$HEAD_BRANCH\",\"base\":\"$TARGET_BRANCH\"}") #Create PR over REST API and get repsonse code
  echo "head: $HEAD_BRANCH, target: $TARGET_BRANCH"
  echo "Create PR Response:"
  echo "Code :   $RESPONSE_CODE"
  if [[ "$RESPONSE_CODE" -ne "201" ]]; #Check if PR worked
  then  
    echo "Could not create PR";
    if [[ "$MSTEAMS" == "true" ]]; #Check if webhook is wanted
    then
      title="Error:*$RESPONSE_CODE" #Title for webhook
      text="Error*$RESPONSE_CODE*while*creating*PR:*$TARGET_PR<br/>PR*by:*$USER<br/>Branch:*$HEAD_BRANCH<br/>Parent*PR:*$MAIN_PR" #Text for webhook
      webhook $title $text #Execute webhook-function
    fi
    exit 1;
  else echo "Created PR";
  fi
}

#Merge PR
function merge_pr ()
{
  TITLE="hotfix auto merged by $USER" #Title for merge
  RESPONSE_CODE=$(curl \
    -o $OUTPUT_PATH -s -w "%{http_code}\n" \
    -X PUT \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/$REPO_FULLNAME/pulls/$newPR_NUMBER/merge \
    --data "{\"commit_title\":\"$TITLE\",\"commit_message\":\"Automated Merge by gitflow-automation\"}") #Merge PR and get repsonse code
  echo "Create Merge Response:"
  echo "Code :   $RESPONSE_CODE"
  if [[ "$RESPONSE_CODE" -ne "200" ]]; #Check if merge worked
  then  
    echo "Could not merge PR";
    if [[ "$MSTEAMS" == "true" ]]; #Check if webhook is wanted
    then
      title="Error:*$RESPONSE_CODE" #Title for webhook
      text="Error*$RESPONSE_CODE*while*merging*PR:*$TARGET_PR<br/>USER:*$USER<br/>Branch:*$HEAD_BRANCH<br/>Parent*PR:*$MAIN_PR" #Text for webhook
      webhook $title $text #Execute webhook-function
    fi
    exit 2;
  else echo "Merged PR";
  fi
}

#Delete head branch
function delete_branch()
{
  DELETE_URL="https://api.github.com/repos/$REPO_FULLNAME/git/refs/heads/$HEAD_BRANCH" #Head branch URL for deletion
  RESPONSE_CODE=$(curl \
    -o $OUTPUT_PATH -s -w "%{http_code}\n" \
    -X DELETE \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "$DELETE_URL") #Delete head branch and get response code
  echo "Delete branch:"
  echo "used url: $DELETE_URL"
  echo "Code : $RESPONSE_CODE"
  if [[ "$RESPONSE_CODE" != "204" ]]; #Check if deletion worked
  then
    echo "Could not delete head"
    exit 1
  fi
}

#Checks
function check_token_is_defined() #Check if Github Token is defined
{
  if [[ -z "$GITHUB_TOKEN" ]];
  then
    echo "Undefined GITHUB_TOKEN environment variable."
    exit 4
  fi
}

function check_is_pr_is_merged() #Check if head PR is merged
{
  echo "$(jq -r ".pull_request.merged" "$GITHUB_EVENT_PATH")"
  if [[ "$(jq -r ".pull_request.merged" "$GITHUB_EVENT_PATH")" == "false" ]];
  then
    echo "This PR has not merged event."
    exit 0
  fi
}

function check_is_pr_branch_has_prefix() #Check if head branch has prefix
{
  echo "$(jq -r ".pull_request.head.ref" "$GITHUB_EVENT_PATH")"
  if [[ "$(jq -r ".pull_request.head.ref" "$GITHUB_EVENT_PATH")" != "$BRANCH_PREFIX"* ]];
  then
    echo "This PR head branch do not have prefix."
    exit 0
  fi
}

function check_is_merged_base_branch_is_trigger() #Check if head branch is not base branch
{
  echo "$(jq -r ".pull_request.base.ref" "$GITHUB_EVENT_PATH")"
  if [[ "$(jq -r ".pull_request.base.ref" "$GITHUB_EVENT_PATH")" != "$BASE_BRANCH" ]];
  then
    echo "This PR base branch is not base branch."
    exit 0
  fi

}

function check_validate() #Execute checks
{
  check_token_is_defined
  check_is_pr_is_merged
  check_is_pr_branch_has_prefix
  check_is_merged_base_branch_is_trigger
}

function hotfix_check() #Check if head branch is a hotfix
{
  if [[ ! $HEAD_BRANCH =~ $BRANCH_PREFIX ]];
  then
    echo "Head branch ($HEAD_BRANCH) is not hotfix."
    exit 0
  fi
  echo "Head branch ($HEAD_BRANCH) is hotfix."
}

#main function
function main()
{
  hotfix_check
  check_validate
  create_pr
  merge_pr
  delete_branch
}

#execute main
main