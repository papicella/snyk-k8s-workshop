# Snyk K8s Integration Workshop

Snyk integrates with Kubernetes, enabling you to import and test your running workloads and identify vulnerabilities in their associated images and configurations that might make those workloads less secure. Once imported, Snyk continues to monitor those workloads, identifying additional security issues as new images are deployed and the workload configuration changes.

In this **hands-on** demo we will achieve the follow

* [Install a k3d K8s cluster on your local machine](#install-a-k3d-k8s-cluster-on-your-local-machine)
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

<img src="https://i.ibb.co/vsYSnX7/snyk-k8s-workshop-1.png" alt="img1" width="500" height="100%" />

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

Now, log in to your Snyk account and navigate to your Organization assigned to you at the start of the labs, click on Integrations. Search for and click Kubernetes. Click Connect from the page that loads, copy the Integration ID. The Snyk Integration ID is a UUID, similar to this format: abcd1234-abcd-1234-abcd-1234abcd1234. Save it for use from your Kubernetes environment in the next step

Instructions link - https://support.snyk.io/hc/en-us/articles/360006368657-Viewing-your-Kubernetes-integration-settings

`Select Integrations link`

<img src="https://i.ibb.co/FKtXDK1/snyk-k8s-workshop-2.png" alt="img2" width="550" height="100%" />

`Search for "Kubernetes" and click on the tile`

<img src="https://i.ibb.co/x5FyLdr/snyk-k8s-workshop-3.png" alt="img3" width="550" height="100%" />

`Click "Connect" to enable the integration`

<img src="https://i.ibb.co/7NhZRny/snyk-k8s-workshop-4.png" alt="img4" width="550" height="100%" />

`Copy the integration ID as we will need it soon`

<img src="https://i.ibb.co/f9yNC8R/snyk-k8s-workshop-5.png" alt="img5" width="550" height="" />

## Install the Snyk Controller into your K8s cluster

Once the repository is added, create a unique namespace for the Snyk controller

```bash
$ kubectl create namespace snyk-monitor
namespace/snyk-monitor created
```
Snyk monitor runs by using your Snyk Integration ID, and using a dockercfg file. If you are not using any private registries which we are not in this demo, create a Kubernetes secret called snyk-monitor containing the Snyk Integration ID from the previous step and run the following command

`Sample command script`

```bash
$ kubectl create secret generic snyk-monitor -n snyk-monitor \
         --from-literal=dockercfg.json={} \
         --from-literal=integrationId=$1
```

`Run the script below passing in your KUBERNETES_INTEGRATION_ID`

```
$ ./3-create-secret-token.sh KUBERNETES_INTEGRATION_ID
secret/snyk-monitor created
```

Install the Snyk Controller as follows

`Sample command script`

```bash
helm upgrade --install snyk-monitor snyk-charts/snyk-monitor \
                          --namespace snyk-monitor \
                          --set clusterName="k3d Dev Workshop cluster"
```

`Run the script below`

```bash
$ ./4-install-snyk-controller.sh
Release "snyk-monitor" does not exist. Installing it now.
NAME: snyk-monitor
LAST DEPLOYED: Tue Jun 15 20:45:54 2021
NAMESPACE: snyk-monitor
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Verify the snyk controller is running without an error

```bash
$ kubectl get all -n snyk-monitor
NAME                               READY   STATUS    RESTARTS   AGE
pod/snyk-monitor-86bfb7795-sp2g7   1/1     Running   0          3m14s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/snyk-monitor   1/1     1            1           3m14s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/snyk-monitor-86bfb7795   1         1         1       3m14s
```

_Note: You can obtain the snyk controller logs as follows_

`Sample command script`

```bash
export POD=`kubectl get pods --namespace snyk-monitor -l "app.kubernetes.io/name=snyk-monitor" -o jsonpath="{.items[0].metadata.name}"`

kubectl logs -n snyk-monitor $POD -f
```

`Run the script below`

```bash
$ ./get-snyk-monitor-logs.sh
{"name":"kubernetes-monitor","hostname":"snyk-monitor-86bfb7795-sp2g7","pid":7,"level":30,"msg":"Cleaned temp storage","time":"2021-06-15T10:47:22.689Z","v":0}
{"name":"kubernetes-monitor","hostname":"snyk-monitor-86bfb7795-sp2g7","pid":7,"level":30,"msg":"Rego policy file does not exist, skipping loading","time":"2021-06-15T10:47:22.694Z","v":0}
{"name":"kubernetes-monitor","hostname":"snyk-monitor-86bfb7795-sp2g7","pid":7,"level":30,"cluster":"k3d Dev Workshop cluster","msg":"starting to monitor","time":"2021-06-15T10:47:22.694Z","v":0}
{"name":"kubernetes-monitor","hostname":"snyk-monitor-86bfb7795-sp2g7","pid":7,"level":30,"namespace":"default","msg":"setting up namespace watch","time":"2021-06-15T10:47:22.755Z","v":0}
{"name":"kubernetes-monitor","hostname":"snyk-monitor-86bfb7795-sp2g7","pid":7,"level":30,"namespaceName":"kube-system","msg":"ignoring blacklisted namespace","time":"2021-06-15T10:47:22.759Z","v":0}
{"name":"kubernetes-monitor","hostname":"snyk-monitor-86bfb7795-sp2g7","pid":7,"level":30,"namespaceName":"kube-public","msg":"ignoring blacklisted namespace","time":"2021-06-15T10:47:22.759Z","v":0}
{"name":"kubernetes-monitor","hostname":"snyk-monitor-86bfb7795-sp2g7","pid":7,"level":30,"namespaceName":"kube-node-lease","msg":"ignoring blacklisted namespace","time":"2021-06-15T10:47:22.759Z","v":0}
{"name":"kubernetes-monitor","hostname":"snyk-monitor-86bfb7795-sp2g7","pid":7,"level":30,"namespace":"snyk-monitor","msg":"setting up namespace watch","time":"2021-06-15T10:47:22.759Z","v":0}
{"name":"kubernetes-monitor","hostname":"snyk-monitor-86bfb7795-sp2g7","pid":7,"level":30,"workloadLocator":{"userLocator":"e31be23e-a59f-476d-b861-f0871a1fc011","cluster":"k3d Dev Workshop cluster","namespace":"snyk-monitor","type":"Deployment","name":"snyk-monitor"},"msg":"attempting to send workload metadata upstream","time":"2021-06-15T10:47:22.889Z","v":0}

...

```


## Deploy some applications to you K8s cluster

TODO://

## Monitor those applications from the Snyk Platform

TODO://

<hr />
Pas Apicella [pas at snyk.io] is an Solution Engineer at Snyk APJ 

