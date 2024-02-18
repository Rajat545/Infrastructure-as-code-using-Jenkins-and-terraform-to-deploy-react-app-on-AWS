
**Step-by-Step Tutorial: Infrastructure as Code with Jenkins, Terraform, and deploy react code in minikube on AWS Deployment**

This tutorial guides you through setting up a jenkins pipeline to deploy a React web application on AWS using Jenkins, Terraform, and kubernetes cluster.

  

**Prerequisites**

Before you start, ensure you have the following tools installed:
  

**1.Aws**

**2.Jenkins**

**3.Terraform**

**4.kubernetes**


  

**Step 1: **Project Setup****

Clone the project repository.

configure aws cli with help of aws secret key

  
  
  

**Step 2: **Install and setup terraform in AWS EC2****

After creating jenkins server

Setup jenkins declarative pipeline script using jenkinsfile

Setup build and deploy docker images to dockerhub

  
  

**Step 3: Terraform AWS Setup**

Create a Terraform script for AWS infrastructure.

Run Terraform commands to apply the configuration.

  
  

**Step 4: Usage**

Push changes to your Github repository.

Observe Jenkins automatically triggering the pipeline.

Watch Terraform provision and deploy the application on AWS.

  

**Contribution :**

1. Install a minikube cluster on 2nd instance

2. Deploy the react game web app on kubernetes cluster
