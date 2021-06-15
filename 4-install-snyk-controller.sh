helm upgrade --install snyk-monitor snyk-charts/snyk-monitor \
                          --namespace snyk-monitor \
                          --set clusterName="k3d Dev Workshop cluster"
