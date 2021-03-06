# Snyk K8s Integration Workshop

Snyk integrates with Kubernetes, enabling you to import and test your running workloads and identify vulnerabilities in their associated images and configurations that might make those workloads less secure. Once imported, Snyk continues to monitor those workloads, identifying additional security issues as new images are deployed and the workload configuration changes.

In this **hands-on** demo we will achieve the follow

* [Install a k3d K8s cluster on your local machine](#install-a-k3d-k8s-cluster-on-your-local-machine)
* [Obtain a Kubernetes Integration Token from Snyk](#obtain-a-kubernetes-integration-token-from-snyk)
* [Install the Snyk Controller into your K8s cluster](#install-the-snyk-controller-into-your-k8s-cluster)
* [Deploy some applications to you K8s cluster](#deploy-some-applications-to-you-k8s-cluster)
* [Monitor those applications from the Snyk Platform](#monitor-those-applications-from-the-snyk-platform)
* [Auto adding workloads into the Snyk Platform](#auto-adding-workloads-into-the-snyk-platform)

## Prerequisites

* kubectl - https://kubernetes.io/docs/tasks/tools/
* helm3 installed - https://helm.sh/docs/intro/install/
* k3d - https://k3d.io/
* Docker Desktop - https://www.docker.com/products/docker-desktop
* snyk CLI - https://support.snyk.io/hc/en-us/articles/360003812538-Install-the-Snyk-CLI

# Workshop Steps

_Note: It is assumed your using a mac for these steps but it should also work on windows or linux with some modifications to the scripts potentially_

Please ensure Docker desktop is running you need it to complete these steps. 

You will be invited into an organization on the Snyk Platform prior to running this workshop. This is the organization you will use for the workshop. The following is an example ORG within the Snyk Platform

![alt tag](https://i.ibb.co/c8BhLYg/snyk-k8s-workshop-1.png)

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
"snyk-charts" has been added to your repositories
```

## Obtain a Kubernetes Integration Token from Snyk

Now, log in to your Snyk account and navigate to your Organization assigned to you at the start of the labs, click on Integrations. Search for and click Kubernetes. Click Connect from the page that loads, copy the Integration ID. The Snyk Integration ID is a UUID, similar to this format: abcd1234-abcd-1234-abcd-1234abcd1234. Save it for use from your Kubernetes environment in the next step

Instructions - https://support.snyk.io/hc/en-us/articles/360006368657-Viewing-your-Kubernetes-integration-settings

`Select Integrations link`

![alt tag](https://i.ibb.co/qMb5TBS/snyk-k8s-workshop-2.png)

`Search for "Kubernetes" and click on the tile`

![alt tag](https://i.ibb.co/cNHzFMZ/snyk-k8s-workshop-3.png)

`Click "Connect" to enable the integration`

![alt tag](https://i.ibb.co/wp1Jtmn/snyk-k8s-workshop-4.png)

Copy the integration ID as we will need it soon

![alt tag](https://i.ibb.co/9pZ5m7k/snyk-k8s-workshop-5.png)

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

Verify the snyk controller is running without an error.

_Note: This can take up to 2 minutes so please wiat for this to be running as shown below_

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

Deploy two java applications as follows

```bash
$ kubectl apply -f msa-apifirst.yaml
deployment.apps/msa-apifirst created
service/msa-apifirst-service created

$ kubectl apply -f springboot-jib.yaml
deployment.apps/spring-boot-jib created
service/spring-boot-jib-service created
```

Verify they are running before you move onto the next step

```bash
$ kubectl get all
NAME                                  READY   STATUS    RESTARTS   AGE
pod/msa-apifirst-77cf47f585-7jxtg     1/1     Running   0          96s
pod/spring-boot-jib-95dff9874-4pvqv   1/1     Running   0          88s

NAME                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/kubernetes                ClusterIP   10.43.0.1       <none>        443/TCP        18h
service/msa-apifirst-service      NodePort    10.43.205.170   <none>        80:31310/TCP   96s
service/spring-boot-jib-service   NodePort    10.43.195.150   <none>        81:31830/TCP   88s

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/msa-apifirst      1/1     1            1           96s
deployment.apps/spring-boot-jib   1/1     1            1           88s

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/msa-apifirst-77cf47f585     1         1         1       96s
replicaset.apps/spring-boot-jib-95dff9874   1         1         1       88s
```

## Monitor those applications from the Snyk Platform

Click on the "**Integrations**" link and then click on the "**Kubernetes**" tile which should show you those two deployments you added to the K8s cluster in the last step

![alt tag](https://i.ibb.co/Qmf88vZ/snyk-k8s-workshop-6.png)

Add both deployments as shown below by clicking on "**Add selected workloads**"

![alt tag](https://i.ibb.co/MPtm0kt/snyk-k8s-workshop-7.png)

Verify both projects were imported

_Note: Ignore the import warning it's just stating it found 0 issues in some of the configuration it serached across _

![alt tag](https://i.ibb.co/qBcRJrx/snyk-k8s-workshop-8.png)

Click on "default/deployment.apps/spring-boot-jib" as showb below

![alt tag](https://i.ibb.co/r5WgN5k/snyk-k8s-workshop-9.png)

Notice how we are shown details about the "Security Configuration" of our deployment which we defined in your YML files for deployment. Take a look at the two YML files we used to deploy our application 

1. msa-apifirst.yaml
2. springboot-jib.yaml

![alt tag](https://i.ibb.co/M7dhJjg/snyk-k8s-workshop-10.png)

You can also test your Kubernetes YML files using "**snyk iac test**" as follows from the snyk cli as shown below. 

_Note: If you include your Kubernetes config YML files in your Source Code Management system they can also get scanned in the UI of Snyk Platform itself_

```bash
$ snyk iac test springboot-jib.yaml

Testing springboot-jib.yaml...


Infrastructure as code issues:
  ??? Container does not drop all default capabilities [Medium Severity] [SNYK-CC-K8S-6] in Deployment
    introduced by input > spec > template > spec > containers[spring-boot-jib] > securityContext > capabilities > drop

  ??? Container could be running with outdated image [Low Severity] [SNYK-CC-K8S-42] in Deployment
    introduced by spec > template > spec > containers[spring-boot-jib] > imagePullPolicy

  ??? Container's UID could clash with host's UID [Low Severity] [SNYK-CC-K8S-11] in Deployment
    introduced by input > spec > template > spec > containers[spring-boot-jib] > securityContext > runAsUser

  ??? Container is running without liveness probe [Low Severity] [SNYK-CC-K8S-41] in Deployment
    introduced by spec > template > spec > containers[spring-boot-jib] > livenessProbe

  ??? Container is running without AppArmor profile [Low Severity] [SNYK-CC-K8S-32] in Deployment
    introduced by metadata > annotations['container > apparmor > security > beta > kubernetes > io/spring-boot-jib']

  ??? Container is running with writable root filesystem [Low Severity] [SNYK-CC-K8S-8] in Deployment
    introduced by input > spec > template > spec > containers[spring-boot-jib] > securityContext > readOnlyRootFilesystem


Organization:      pas.apicella-41p
Type:              Kubernetes
Target file:       springboot-jib.yaml
Project name:      snyk-k8s-workshop
Open source:       no
Project path:      springboot-jib.yaml

Tested springboot-jib.yaml for known issues, found 6 issues
```

## Auto adding workloads into the Snyk Platform

Importing your Kubernetes application from the Snyk Platform works well but potentially you will want to auto import workloads as they ae deployed to Kubernetes which can be done using the steps below

Retrieve your organisation ID from the Snyk Platform by clicking on "**Settings**" and then copying your ID 

![alt tag](https://i.ibb.co/Yyh083R/snyk-k8s-workshop-11.png)

You will find a Kubernetes YML file named "**person-K8s.yaml**" open it up and add your organisation ID from above as indicated below by replacing "**ORG_ID_HERE**"

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: snyk-person-api
  annotations:
    orgs.k8s.snyk.io/v1: ORG_ID_HERE
```

Deploy as follows and wait for the POD from the Deploym ent to be up and running 

```bash
$ kubectl apply -f person-K8s.yaml
deployment.apps/snyk-person-api created
service/snyk-person-api-lb created

$ kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
msa-apifirst-77cf47f585-7jxtg      1/1     Running   0          84m
spring-boot-jib-95dff9874-4pvqv    1/1     Running   0          84m
snyk-person-api-756d9c5dbc-rmhnw   1/1     Running   0          49s
```

After a few minutes we should see the person API workload appear in the Snyk Platform as shown below

![alt tag](https://i.ibb.co/Cv9b5N7/snyk-k8s-workshop-12.png)
![alt tag](https://i.ibb.co/kXPGSYt/snyk-k8s-workshop-13.png)

Thanks for attending and completing this workshop

![alt tag](https://i.ibb.co/7tnp1B6/snyk-logo.png)

<hr />
Pas Apicella [pas at snyk.io] is an Solution Engineer at Snyk APJ 

