#!/bin/bash
set -e

#Output
OUTPUT_PATH=".output"

#Information from $GITHUB_EVENT_PATH
event_json=$(cat $GITHUB_EVENT_PATH)

USER=$(echo $event_json | jq '.pull_request.user.login' | sed 's/"//g')
HEAD_BRANCH=$(echo $event_json | jq '.pull_request.head.ref' | sed 's/"//g')
REPO_FULLNAME=$(echo $event_json | jq '.repository.full_name' | sed 's/"//g')
PR_NUMBER=$(echo $event_json | jq '.number' | sed 's/"//g')
newPR_NUMBER=$((PR_NUMBER + 1))
MAIN_PR=$(echo $event_json | jq '.pull_request.html_url' | sed 's/"//g')
TARGET_PR="https://github.com/$REPO_FULLNAME/pull/$newPR_NUMBER"

# #test
# echo $USER
# echo $HEAD_BRANCH
# echo $REPO_FULLNAME
# echo $PR_NUMBER
# echo $MAIN_PR
# echo $TARGET_BRANCH

#webhook to Microsoft Teams
function webhook ()
{
  WEBHOOK_URL=${MSTEAMS_WH}

  TITLE=$1

  COLOR="d7000b"

  TEXT=$2

  MESSAGE=$( echo ${TEXT} | sed 's/"/\"/g' | sed "s/'/\'/g" | sed 's/*/ /g' )
  TITLE=$( echo ${TITLE} | sed 's/"/\"/g' | sed "s/'/\'/g" | sed 's/*/ /g' )
  JSON="{\"title\": \"${TITLE}\", \"themeColor\": \"${COLOR}\", \"text\": \"${MESSAGE}\" }"

  curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}"
}

#create pr
function create_pr ()
{
  TITLE="hotfix auto merged by $USER"

  # RESPONSE_CODE=$(gh pr create -a "$USER" -H "$HEAD_BRANCH" -B "$TARGET_BRANCH" -t "$TITLE" -b "Automated PR by gitflow-automation")
  RESPONSE_CODE=$(curl \
  -o $OUTPUT_PATH -s -w "%{http_code}\n" \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$REPO_FULLNAME/pulls \
  --data "{\"title\":\"$TITLE\",\"body\":\"Automated PR by gitflow-automation\",\"head\":\"$HEAD_BRANCH\",\"base\":\"$TARGET_BRANCH\"}")

  echo "head: $HEAD_BRANCH, target: $TARGET_BRANCH"
  echo "Create PR Response:"
  echo "Code :   $RESPONSE_CODE"

  if [[ "$RESPONSE_CODE" -ne "201" ]];
  then  
    echo "Could not create PR";

    title="Error:*$RESPONSE_CODE";

    text="Error*$RESPONSE_CODE*while*creating*PR:*$TARGET_PR<br/>PR*by:*$USER<br/>Branch:*$HEAD_BRANCH<br/>Parent*PR:*$MAIN_PR";

    webhook $title $text;

    exit 1;
  else echo "Created PR";
  fi
}

#merge pr
function merge_pr ()
{
  TITLE="hotfix auto merged by $USER"

  # RESPONSE_CODE=$(gh api --method PUT -H "Accept: application/vnd.github+json" /repos/$REPO_FULLNAME/pulls/$PR_NUMBER/merge -f commit_title=$TITLE -f commit_message='Automated Merge by gitflow-automation')
  RESPONSE_CODE=$(curl \
  -o $OUTPUT_PATH -s -w "%{http_code}\n" \
  -X PUT \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$REPO_FULLNAME/pulls/$newPR_NUMBER/merge \
  --data "{\"commit_title\":\"$TITLE\",\"commit_message\":\"Automated Merge by gitflow-automation\"}")

  echo "Create Merge Response:"
  echo "Code :   $RESPONSE_CODE"

  if [[ "$RESPONSE_CODE" -ne "200" ]];
  then  
    echo "Could not merge PR";

    title="Error:*$RESPONSE_CODE";

    text="Error*$RESPONSE_CODE*while*merging*PR:*$TARGET_PR<br/>USER:*$USER<br/>Branch:*$HEAD_BRANCH<br/>Parent*PR:*$MAIN_PR";

    webhook $title $text;

    exit 2;
  else echo "Merged PR";
  fi
}

#delete head
function delete_branch()
{
  DELETE_URL="https://api.github.com/repos/$REPO_FULLNAME/git/refs/heads/$HEAD_BRANCH"
  RESPONSE_CODE=$(curl \
  -o $OUTPUT_PATH -s -w "%{http_code}\n" \
    -X DELETE \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "$DELETE_URL")
  echo "Delete branch:"
  echo "used url: $DELETE_URL"
  echo "Code : $RESPONSE_CODE"
  if [[ "$RESPONSE_CODE" != "204" ]];
  then
    echo "Could not delete head"
    exit 1
  fi
}

# #check merge
# function approve_merge ()
# {
#   # RESPONSE_CODE=$(gh api -H "Accept: application/vnd.github+json" /repos/$REPO_FULLNAME/pulls/$PR_NUMBER/merge)
#   RESPONSE_CODE=$(curl \
#   -s -o /dev/null -w "%{http_code}\n" \
#   --data "{\"event\":\"APPROVE\"}" \
#   -X POST \
#   -H "Authorization: Bearer $GITHUB_TOKEN" \
#   -H "Accept: application/vnd.github+json" \
#   -H "X-GitHub-Api-Version: 2022-11-28" \
#   "https://api.github.com/repos/$REPO_FULLNAME/pulls/$newPR_NUMBER/reviews")

#   echo "Approve PR Response:"

#   echo "Code : $RESPONSE_CODE"

#   if [[ "$RESPONSE_CODE" -ne "204" ]];
#   then  
#     echo "Merge has gone wrong";

#     title="Error:*$RESPONSE_CODE";

#     text="Error*$RESPONSE_CODE*while*approving*PR:*$TARGET_PR<br/>USER:*$USER<br/>Branch:*$HEAD_BRANCH<br/>Parent*PR:*$MAIN_PR";

#     webhook $title $text;

#     exit 3;
#   else echo "Merged PR";
#   fi
# }

#checks
function check_token_is_defined()
{
  if [[ -z "$GITHUB_TOKEN" ]];
  then
    echo "Undefined GITHUB_TOKEN environment variable."
    exit 4
  fi
}

# function check_bot_token_is_defined()
# {
#   if [[ "$BOT_TOKEN" != null ]];
#   then
#     echo "Bot Token Avaliable"
#     IS_NEED_APPROVE=true    
#   else echo "Bot Token not Avaliable"
#   fi
# }

function check_is_pr_is_merged()
{
  echo "$(jq -r ".pull_request.merged" "$GITHUB_EVENT_PATH")"
  if [[ "$(jq -r ".pull_request.merged" "$GITHUB_EVENT_PATH")" == "false" ]];
  then
    echo "This PR has not merged event."
    exit 0
  fi
}

function check_is_pr_branch_has_prefix()
{
  echo "$(jq -r ".pull_request.head.ref" "$GITHUB_EVENT_PATH")"
  if [[ "$(jq -r ".pull_request.head.ref" "$GITHUB_EVENT_PATH")" != "$BRANCH_PREFIX"* ]];
  then
    echo "This PR head branch do not have prefix."
    exit 0
  fi
}

function check_is_merged_base_branch_is_trigger()
{
  echo "$(jq -r ".pull_request.base.ref" "$GITHUB_EVENT_PATH")"
  if [[ "$(jq -r ".pull_request.base.ref" "$GITHUB_EVENT_PATH")" != "$BASE_BRANCH" ]];
  then
    echo "This PR base branch is not base branch."
    exit 0
  fi

}

function check_validate() 
{
  check_token_is_defined
  # check_bot_token_is_defined
  check_is_pr_is_merged
  check_is_pr_branch_has_prefix
  check_is_merged_base_branch_is_trigger
}

function hotfix_check()
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
  echo "Start"
  echo "Checks:"
  hotfix_check
  check_validate
  echo "Create:"
  create_pr
  # if [[ "$IS_NEED_APPROVE" == "true" ]];
  # then
  #   echo "Approve:"
  #   approve_pr
  # fi
  echo "Merge:"
  merge_pr
  echo "Delete:"
  delete_branch
  echo "Finished"
}

#execute main
main