## Seup GO.cd for serverless CI/CD with AWS CodeCommit

This UserData script will configure an Amazon EC2 instance to run a GO.cd pipeline to deploy applications build with the [Serverless Framework](https://serverless.com).

Prerequisites:

* Your Amazon EC2 instance role must have full access to CodeCommit
  * Attaching the AWSCodeCommitFullAcces policy will work. More info about CodeCommit polices here: http://docs.aws.amazon.com/codecommit/latest/userguide/auth-and-access-control-iam-identity-based-access-control.html
* You will need to put the https path to your repo in an environment variable called REPO_URL

Copy the contents of this file into the UserData field of your Amazon Linux instance to automatically install the Go Server and Agent as well as a couple of plugins:

* [Slack Build Notifier](https://github.com/ashwanthkumar/gocd-slack-build-notifier)
* [Yaml Pipeline Configuration](https://github.com/tomzo/gocd-yaml-config-plugin)
