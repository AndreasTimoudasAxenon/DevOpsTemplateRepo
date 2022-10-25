# Axenon DevOps Template for new orgs

## WorkFlows

### pr-dev-branch.yml

A workflow that runs when a pull request is opened against the `dev` branch.
Triggers is a pull request is `opened`, `synchronized` or `edited`. This means that if the workflow
fails because of wrong test specified in the pull request template or because code doesn't pass the test
all new commits to the feature-branch will get synchronized to the pull request and the workflow will re-run.

### push-develop-branch.yml

A workflow that runs when a pull request is approved and pushed to `dev` branch.

When a pull request is approved a "change set" is created under the hood, `sfdx sgd:source:delta --to "HEAD" --from "HEAD^"`. This means that the change set contains everything from the recent commit to the previous commit on the branch.

This change set is later on deployed to the sandbox stored as `SFDX_DEV_URL` in a secret. The deployment is done in
below fashion:
`sfdx force:source:deploy -p "changed-sources/force-app" --testlevel RunLocalTests --json`
meaning all test on that enviroment is run and a log is returned when finished. 
This job is assumed to never fail.