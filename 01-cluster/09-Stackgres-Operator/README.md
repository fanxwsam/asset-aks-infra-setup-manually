# Setup Stackgres Postgresql Operator (stackgres.io)

### Step 1: Setting up the enviroment Setting up a Kubernetes Cluster
Prometheus should be installed.
refer to folder '08-Prometheus-Grafana'

### Step 2: Install Stackgres
Create the stackgres namespace:
```
kubectl create namespace stackgres
```

#### Important Notice: do not use this command, it will cause installation fail
```
kubectl annotate namespace stackgres linkerd.io/inject=enabled
```



Add the helm repo:
```
helm repo add stackgres-charts https://stackgres.io/downloads/stackgres-k8s/stackgres/helm/
helm repo update
```

Create storage class cstor-mirror
```
kubectl apply -f 01-sc-aks-cstor-mirror.yml
```

#helm uninstall stackgres-operator --namespace stackgres

Install the Operator:
```
helm install stackgres-operator stackgres-charts/stackgres-operator `
               --create-namespace `
               --namespace stackgres `
                --set grafana.autoEmbed=true `
                --set-string grafana.webHost=prometheus-grafana.monitoring `
                --set-string grafana.secretNamespace=monitoring `
                --set-string grafana.secretName=grafana-credentials-secret `
                --set-string grafana.secretUserKey=admin-user `
                --set-string grafana.secretPasswordKey=admin-password `
                --set-string adminui.service.type=ClusterIP `
                --set-string cluster.pods.persistentVolume.storageclass=cstor-mirror `
                --set-string cluster.pods.persistentVolume.size=5Gi `
                --set-string cluster.pods.scheduling.nodeSelector.app=dbcluster-apps `
                --set-string jobs.nodeSelector.app=system-apps `
                --set-string operator.nodeSelector.app=system-apps `
                --set-string restapi.nodeSelector.app=system-apps
                
```

Depoy the ingress:
```
kubectl apply -f 02-stackgres-ui-service-ingress-public.yml
```


NOT APPLIED in this environment. The command in existing AWS env with cert.crt, cert.key. .
```
helm install --namespace stackgres stackgres-operator \
    --set grafana.autoEmbed=true \
    --set-string grafana.webHost=akspoc-metrics-grafana.monitoring \
    --set-string grafana.secretNamespace=monitoring \
    --set-string grafana.secretName=grafana-credentials-secret \
    --set-string grafana.secretUserKey=admin-user \
    --set-string grafana.secretPasswordKey=admin-password \
    --set-string adminui.service.type=ClusterIP \
    --set-string cluster.pods.persistentVolume.storageclass=cstor-mirror \
    --set-string cluster.pods.persistentVolume.size=20Gi \
    --set-string cert.crt="$(base64 server.crt)" \
    --set-string cert.key="$(base64 server.key)" \
stackgres-charts/stackgres-operator
```

If there is an issue "x509: certificate signed by unknown authority.", in the helm upgrade command, add the configuration below:
```
--set cert.resetCerts=true
```



