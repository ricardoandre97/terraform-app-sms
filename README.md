# Deploy SMS app using Terraform and Fargate in AWS :)

## What does it do?
Well, it deploys some resources to AWS to host a pretty basic containerized fargate app written in Golang. At the end, you can simply type a message and you will receive it in your cellphone :)
`NOTE:` As requested, the ARN topic of the SNS lives in a parameter in SSM, and it's retrieved from there each time you send a meesage through the app.

## Setup
This setup is split in three main parts:
* Deploy the needed resources using Terraform
* Push app's code to a CodeCommit repository created by Terraform
* Go to the LoadBalancer DNS and play with the app!

# Assumptions
* You have a terraform version > v0.12.15 installed locally
* You have your AWS credentials configured with the default profile and region at ~/.aws/credentials. (If you don't, you can add your custom config to the main file in the terraform repo)
* The user you are using to deploy the AWS resources is capable of using iam:PassRole to pass IAM roles to resources. You can add below policy to your user to grant this permission which is required for this case.
```sh
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "iam:PassRole",
                "iam:GetRole"
            ],
            "Resource": "arn:aws:iam::YOUR_ACCOUNT:role/cloudformation-role-terraform-codepipeline",
            "Effect": "Allow"
        }
    ]
}
```
`WARNING:` You might find `AccessDeniedException: user "X" is not authorized to perform: iam:PassRole on resource: "Y"` error in the deployment if your user doesn't have the policy. You MUST fulfill this requirement, otherwise, things won't look good for you.

# Let's get the party started
* Please clone the github repo somewhere in your machine and cd to that directory
```sh
git clone https://github.com/ricardoandre97/terraform-app-sms ~/terraform-app-sms
cd ~/terraform-app-sms
```
Check the variables file at `terraform/variables.tf` and please change the phone number and use yours. Double check this, because if you type a wrong number, you won't get anything.
* Let's go to the terraform directory and type
```sh
cd terraform
terraform init
terraform plan
terraform apply -> Confirm with yes
```
Now, you will need to wait for some minutes :)

Once Terraform finishes, you will see three outputs.
* A LB DNS
* A CodeCommit Repo URL over HTTPS
* A Pipeline url

Please, clone the codecommit repo locally somewhere. (This repo will hold the source code for the application. This will also trigger the pipeline)
```sh
git clone CODECOMMIT_URL_HERE ~/go-sms-app
```
* `NOTE:` You need to have IAM git credentials to clone a CodeCommit repo. You can enable it on the IAM console easily. You have to do this on your own.

Let's push some code to the repo to automatically deploy the app!
```sh
cd ~/go-sms-app
# Copy the source code from teh github repo
cp -r ~/terraform-app-sms/src/* .
git add .
git commit -m "DevOps Rocks!"
git push -u origin master
```

Now, please go to the Pipeline URL (Check the terraform outputs) and wait for the pipeline to complete.

Once it  finishes, you can go to the LoadBalancer Output (Check terraform again), copy and paste the url in your browser and see the magic! You should see a simple form, please type something and send it! You should get that message in the phone number you provided :)

# Deletion - Extremely important!

As you might saw, the Pipeline deploys the containers through CloudFormation, which is a nice tool to keep an eye on your Deployments at the same time of providing you with cool rollback features.

Now, if you want to destroy the app that you just deployed, you will need to manually go to the cloudformation console and delete the Stack. (You can click on the Pipeline Deployment details and it will get you there!)

As soon as the stack deletion completes, you can go to your terminal and type:
```sh
terraform destroy -> Say yes!
```
`NOTE:` You might see an error when deleting the S3 artifact bucket created by CodePipeline. If so, please go to the bucket, and delete it's content, then try again.

That's it! 