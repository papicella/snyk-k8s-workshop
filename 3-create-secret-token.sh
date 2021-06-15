kubectl create secret generic snyk-monitor -n snyk-monitor \
         --from-literal=dockercfg.json={} \
         --from-literal=integrationId=$1
