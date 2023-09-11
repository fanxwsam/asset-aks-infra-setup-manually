helm repo add hazelcast https://hazelcast-charts.s3.amazonaws.com/
helm repo update

kubectl create namespace dev-svc

helm install operator hazelcast/hazelcast-platform-operator `
                     --version=5.6.0 `
                     --set installCRDs=true `
                     --namespace=dev-svc `
                     --set nodeSelector.app=user-apps

helm install operator-crds hazelcast/hazelcast-platform-operator-crds --version=5.6.0 --namespace=dev-svc

helm install operator hazelcast/hazelcast-platform-operator --version=5.6.0 --namespace=dev-svc --set nodeSelector.app=user-apps


az aks show --resource-group aks-devuat-rg --name aks-devuat --query "networkProfile.networkPlugin"
az aks show --resource-group aks-devuat-rg --name aks-devuat --query "networkProfile.networkPolicy"












