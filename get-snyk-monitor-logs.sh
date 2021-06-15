export POD=`kubectl get pods --namespace snyk-monitor -l "app.kubernetes.io/name=snyk-monitor" -o jsonpath="{.items[0].metadata.name}"`

kubectl logs -n snyk-monitor $POD -f

