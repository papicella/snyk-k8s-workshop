# Snyk K8s Integration Workshop

Snyk integrates with Kubernetes, enabling you to import and test your running workloads and identify vulnerabilities in their associated images and configurations that might make those workloads less secure. Once imported, Snyk continues to monitor those workloads, identifying additional security issues as new images are deployed and the workload configuration changes.

In this **hands-on** demo we will achieve the follow

* [Install a k3d K8s cluster on your local machine](#install-a-k3d-k8s-cluster-on-your-local-machine)
* Install a k3d K8s cluster on your local machine
* Obtain a Kubernetes Integration Token from Snyk
* Install the Snyk Controller into your K8s cluster
* Deploy some applications to you K8s cluster
* Monitor those applications from the Snyk Platform

## Prerequisites

* kubectl - https://kubernetes.io/docs/tasks/tools/
* helm3 installed - https://helm.sh/docs/intro/install/
* 
# Workshop Steps

_Note: It is assumed your using a mac for these steps but it should also work on windows or linux_

You will be invited into an organization on the Snyk Platform prior to running this workshop. This is the organization you will use for the workshop. The following is an example ORG within the Snyk Platform

<img src="https://i.ibb.co/vsYSnX7/snyk-k8s-workshop-1.png" alt="img1" width="450" />

## Install a k3d K8s cluster on your local machine

Install k3d using the instructions from the link here - https://k3d.io/

```
$ k3d --version
k3d version v4.4.1
k3s version latest (default)
```


## Obtain a Kubernetes Integration Token from Snyk


## Install the Snyk Controller into your K8s cluster


## Deploy some applications to you K8s cluster


## Monitor those applications from the Snyk Platform



<hr />
Pas Apicella [pas at snyk.io] is an Solution Engineer at Snyk APJ 

