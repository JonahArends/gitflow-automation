# Gitflow automation

## English:

### Possibility 1
- run workflow.sh from this repository
```yaml
name: gitflow-automation
on:
  pull_request:
    types: [closed]

jobs:
  if_merged:
    create-auto-pr:
      name: Gitflow Automation
      runs-on: ubuntu-latest

      steps:
        - uses: JonahArends/gitflow-automation-MSTeam-webhook@master
          env:
            BASE_BRANCH: "main"
            BRANCH_PREFIX: "hotfix"
            TARGET_BRANCH: "develop"
            GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
            MSTEAMS: "true"
            MSTEAMS_WH: ${{ secrets.MSTEAMS_WH }} #secret recommended
```
- `BASE_BRANCH`: Base-branch of the pull request that is to trigger the workflow
- `BRANCH_PREFIX`: Prefix of the branch that is to trigger the workflow
- `TARGET_BRANCH`: Branch into which the workflow should automatically merge
- `GITHUB_TOKEN`: Your Github token for authentication
- `MSTEAMS`: Turn the Microsoft Teams webhook on (```"true"```) or off (```"false"```)
- `MSTEAMS_WH`: Create a Github secret for the Microsoft Teams webhook URL with the name "MSTEAMS_WH"

#
### Possibility 2
- run workflow.sh from own repository

```yaml
name: gitflow-automation
on:
  pull_request:
    types: [closed]

jobs:
  if_merged:
    create-auto-pr:
      name: Gitflow Automation
      runs-on: ubuntu-latest

      steps:
        - uses: actions/checkout@v3.3.0
          with:
            ref: main

        - name: gitflow-automation
          run: | 
            chmod +x path/to/workflow.sh && path/to/workflow.sh
          env:
            BASE_BRANCH: "main"
            BRANCH_PREFIX: "hotfix"
            TARGET_BRANCH: "develop"
            GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
            MSTEAMS: "true"
            MSTEAMS_WH: ${{ secrets.MSTEAMS_WH }} #secret recommended
```
- `BASE_BRANCH`: Base-branch of the pull request that is to trigger the workflow
- `BRANCH_PREFIX`: Prefix of the branch that is to trigger the workflow
- `TARGET_BRANCH`: Branch into which the workflow should automatically merge
- `GITHUB_TOKEN`: Your Github token for authentication
- `MSTEAMS`: Turn the Microsoft Teams webhook on (```"true"```) or off (```"false"```)
- `MSTEAMS_WH`: Create a Github secret for the Microsoft Teams webhook URL with the name "MSTEAMS_WH"

## What is "gitflow"?

> #### Maintenance or “hotfix” branches are used to quickly patch production releases. Hotfix branches are a lot like release branches and feature branches except they're based on main instead of develop.
> #### This is the only branch that should fork directly off of main. As soon as the fix is complete, it should be merged into both main and develop (or the current release branch), and main should be tagged with an updated version number.
> ![gitflow](https://wac-cdn.atlassian.com/dam/jcr:cc0b526e-adb7-4d45-874e-9bcea9898b4a/04%20Hotfix%20branches.svg?cdnVersion=760 "")
##### Source: https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow

#

## German:

### Möglichkeit 1
- workflow.sh aus diesem Repository ausführen

```yaml
name: gitflow-automation
on:
  pull_request:
    types: [closed]

jobs:
  if_merged:
    create-auto-pr:
      name: Gitflow Automation
      runs-on: ubuntu-latest

      steps:
        - uses: actions/checkout@v3.3.0
          with:
            ref: main

        - name: gitflow-automation
          run: | 
            chmod +x path/to/workflow.sh && path/to/workflow.sh
          env:
            BASE_BRANCH: "main"
            BRANCH_PREFIX: "hotfix"
            TARGET_BRANCH: "develop"
            GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
            MSTEAMS: "true"
            MSTEAMS_WH: ${{ secrets.MSTEAMS_WH }} #secret empfohlen
```
- `BASE_BRANCH`: Base-branch, des Pull Requests, der den Workflow auslösen soll
- `BRANCH_PREFIX`: Prefix der Branch, die den Workflow auslösen soll
- `TARGET_BRANCH`: Branch, in die der Workflow automatisch mergen soll
- `GITHUB_TOKEN`: Dein Github-Token zur Authentifizierung
- `MSTEAMS`: Microsoft Teams Webhook an (```"true"```) oder aus (```"false"```) schalten
- `MSTEAMS_WH`: Erstelle ein Github Secret für die Microsoft Teams Webhook-URL mit dem Namen "MSTEAMS_WH"

#
### Möglichkeit 2
- workflow.sh aus eigenem Repository ausführen

```yaml
name: gitflow-automation
on:
  pull_request:
    types: [closed]

jobs:
  if_merged:
    create-auto-pr:
      name: Gitflow Automation
      runs-on: ubuntu-latest

      steps:
        - uses: actions/checkout@v3.3.0
          with:
            ref: main

        - name: gitflow-automation
          run: | 
            chmod +x path/to/workflow.sh && path/to/workflow.sh
          env:
            BASE_BRANCH: "main"
            BRANCH_PREFIX: "hotfix"
            TARGET_BRANCH: "develop"
            GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
            MSTEAMS: "true"
            MSTEAMS_WH: ${{ secrets.MSTEAMS_WH }} #secret empfohlen
```
- `BASE_BRANCH`: Base-branch, des Pull Requests, der den Workflow auslösen soll
- `BRANCH_PREFIX`: Prefix der Branch, die den Workflow auslösen soll
- `TARGET_BRANCH`: Branch, in die der Workflow automatisch mergen soll
- `GITHUB_TOKEN`: Dein Github-Token zur Authentifizierung
- `MSTEAMS`: Microsoft Teams Webhook an (```"true"```) oder aus (```"false"```) schalten
- `MSTEAMS_WH`: Erstelle ein Github Secret für die Microsoft Teams Webhook-URL mit dem Namen "MSTEAMS_WH"

## Was ist "gitflow"?

> #### Wartungs- oder "Hotfix"-Branches werden verwendet, um Produktionsversionen schnell zu patchen. Hotfix-Branches sind ähnlich wie Release-Branches und Feature-Branches, nur dass sie auf Main statt auf Develop basieren.
> #### Dies ist der einzige Branch, der direkt von main abzweigen sollte. Sobald die Korrektur abgeschlossen ist, sollte sie sowohl in den Haupt- als auch in den Entwicklungsbranch (oder den aktuellen Veröffentlichungsbranch) eingebunden werden, und der Hauptbranch sollte mit einer aktualisierten Versionsnummer versehen werden.
> ![gitflow](https://wac-cdn.atlassian.com/dam/jcr:cc0b526e-adb7-4d45-874e-9bcea9898b4a/04%20Hotfix%20branches.svg?cdnVersion=760 "Quelle: ")
##### Quelle: https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow
