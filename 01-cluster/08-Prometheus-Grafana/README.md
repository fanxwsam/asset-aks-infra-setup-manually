# Prometheus & Grafana
Create a namespace:
```
kubectl create namespace monitoring
# with the annotation of linkerd.io/inject=enabled, installation will fail
# kubectl annotate namespace monitoring linkerd.io/inject=enabled
```

Create grafana admin secret:
```
kubectl create secret generic grafana-credentials-secret `
               --namespace=monitoring `
               --from-literal=admin-user=admin `
               --from-literal=admin-password=p@ssw0rd$1%-#
```

Configure the storage class:
```
kubectl apply -f 01-storage-class-aks-cstor-mirror.yml
```

Add the Repo:
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

Deploy Prometheus:
```
### Except 'prometheus-node-exporter', all the pods will be installed on system nodes:
helm install prometheus prometheus-community/kube-prometheus-stack `
               -n monitoring `
               -f .\02-prometheus-grafana-values.yml `
               --set prometheus.service.nodePort=30000 `
               --set prometheus.service.type=NodePort `
               --set kubeEtcd.enabled=false `
               --set kubeControllerManager.enabled=false
```

Check that it's running:
```
kubectl --namespace monitoring get pods -l "release=prometheus"
```

Add the CStor Prometheus Alerts:
```
kubectl apply -f 03-cstor-prometheus-alerts.yml
```

Install the Service Ingress
```
kubectl apply -f 04-grafana-service-ingress-public.yml
```

Install the Grafana Service Ingress
```
kubectl apply -f 06-prometheus-service-ingress-public.yml
```

--------
## Update Prometheus / Grafana:
```
Please do not apply this command <br>
The command has been applied in installation stage, when there are some new parameters need to be changed, please use the command below:
helm upgrade akspoc-metrics --namespace monitoring prometheus-community/kube-prometheus-stack -f cluster/prometheus-grafana/prometheus-grafana-values.yaml
```
