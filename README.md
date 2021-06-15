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
* k3d - https://k3d.io/
* Docker Desktop - https://www.docker.com/products/docker-desktop

# Workshop Steps

_Note: It is assumed your using a mac for these steps but it should also work on windows or linux_

You will be invited into an organization on the Snyk Platform prior to running this workshop. This is the organization you will use for the workshop. The following is an example ORG within the Snyk Platform

<img src="https://i.ibb.co/vsYSnX7/snyk-k8s-workshop-1.png" alt="img1" width="500" />

## Install a k3d K8s cluster on your local machine

Install k3d using the instructions from the link here - https://k3d.io/

```bash
$ k3d --version
k3d version v4.4.1
k3s version latest (default)
```

Create a K8s cluster as shown below

```bash
$ k3d cluster create snyk-k8s-workshop --servers 1 --agents 2
INFO[0000] Prep: Network
INFO[0003] Created network 'k3d-snyk-k8s-workshop'
INFO[0003] Created volume 'k3d-snyk-k8s-workshop-images'
INFO[0004] Creating node 'k3d-snyk-k8s-workshop-server-0'
INFO[0004] Creating node 'k3d-snyk-k8s-workshop-agent-0'
INFO[0004] Creating node 'k3d-snyk-k8s-workshop-agent-1'
INFO[0004] Creating LoadBalancer 'k3d-snyk-k8s-workshop-serverlb'
INFO[0005] Starting cluster 'snyk-k8s-workshop'
INFO[0005] Starting servers...
INFO[0005] Starting Node 'k3d-snyk-k8s-workshop-server-0'
INFO[0013] Starting agents...
INFO[0013] Starting Node 'k3d-snyk-k8s-workshop-agent-0'
INFO[0024] Starting Node 'k3d-snyk-k8s-workshop-agent-1'
INFO[0033] Starting helpers...
INFO[0033] Starting Node 'k3d-snyk-k8s-workshop-serverlb'
INFO[0034] (Optional) Trying to get IP of the docker host and inject it into the cluster as 'host.k3d.internal' for easy access
INFO[0036] Successfully added host record to /etc/hosts in 4/4 nodes and to the CoreDNS ConfigMap
INFO[0036] Cluster 'snyk-k8s-workshop' created successfully!
INFO[0036] --kubeconfig-update-default=false --> sets --kubeconfig-switch-context=false
INFO[0036] You can now use it like this:
kubectl config use-context k3d-snyk-k8s-workshop
kubectl cluster-info
```

View the K8s nodes

```bash
$ kubectl get nodes
NAME                             STATUS   ROLES                  AGE     VERSION
k3d-snyk-k8s-workshop-server-0   Ready    control-plane,master   3m36s   v1.20.5+k3s1
k3d-snyk-k8s-workshop-agent-0    Ready    <none>                 3m28s   v1.20.5+k3s1
k3d-snyk-k8s-workshop-agent-1    Ready    <none>                 3m19s   v1.20.5+k3s1
```

Run the following command in order to add the Snyk Charts repository to Helm

```bash
$ helm repo add snyk-charts https://snyk.github.io/kubernetes-monitor/
"snyk-charts" already exists with the same configuration, skipping
```

## Obtain a Kubernetes Integration Token from Snyk


## Install the Snyk Controller into your K8s cluster


## Deploy some applications to you K8s cluster


## Monitor those applications from the Snyk Platform



<hr />
Pas Apicella [pas at snyk.io] is an Solution Engineer at Snyk APJ 

