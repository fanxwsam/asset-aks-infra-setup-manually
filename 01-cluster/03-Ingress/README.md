## step-01: Ingress position in the architecture below
![Image](/01-cluster/images/uat-arch-01.png)

## Step-02: Create Static Public IP
```t
# Get the resource group name of the AKS cluster 
az aks show --resource-group aks-devuat-rg --name aks-devuat --query nodeResourceGroup -o tsv

the value is: MC_aks-devuat-rg_aks-devuat_australiaeast

# TEMPLATE - Create a public IP address with the static allocation
az network public-ip create --resource-group <REPLACE-OUTPUT-RG-FROM-PREVIOUS-COMMAND> --name myAKSPublicIPForIngress --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv

# REPLACE - Create Public IP: Replace Resource Group value
az network public-ip create `
    --resource-group MC_aks-devuat-rg_aks-devuat_australiaeast `
    --version IPv4 `
    --location australiaeast `
    --zone 1 2 3 `
    --name DEVUAT_PublicIPForIngress `
    --sku Standard `
    --allocation-method static `
    --query publicIp.ipAddress `
    -o tsv

```
- Make a note of Static IP which we will use in next step when installing Ingress Controller
```t
# Make a note of Public IP created for Ingress
20.248.137.117
```

## Step-03: Install Ingress Controller
```t
# Install Helm3 (if not installed)
brew install helm


# Add the official stable repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

#  Customizing the Chart Before Installing. 
helm show values ingress-nginx/ingress-nginx

# Use Helm to deploy an NGINX ingress controller in namespace ingress-nginx
# ( On Windows, use command below)
helm install ingress-nginx ingress-nginx/ingress-nginx `
    --namespace ingress-nginx `
    --create-namespace `
    --set controller.replicaCount=2 `
	--set controller.nodeSelector."kubernetes\.io/os"=linux `
    --set controller.nodeSelector."app"=system-apps `
	--set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux `
    --set controller.admissionWebhooks.patch.nodeSelector."app"=system-apps `
    --set controller.admissionWebhooks.patch.image.digest="" `
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux `
	--set defaultBackend.nodeSelector."app"=system-apps `
	--set controller.extraArgs.enable-ssl-passthrough="" `
    --set controller.service.externalTrafficPolicy=Local `
    --set controller.service.loadBalancerIP="20.248.137.117" `
    --set prometheus.create=true `
    --values values.yml



# Install Internal Ingress Nginx
 helm install nginx-ingress-internal ingress-nginx/ingress-nginx `
    --namespace ingress-nginx-internal `
    --create-namespace `
    --set controller.replicaCount=2 `
    --set controller.nodeSelector."kubernetes\.io/os"=linux `
    --set controller.nodeSelector."app"=system-apps `
    --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux `
    --set controller.admissionWebhooks.patch.nodeSelector."app"=system-apps `
    --set controller.admissionWebhooks.patch.image.digest="" `
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux `
    --set defaultBackend.nodeSelector."app"=system-apps `
    --set controller.extraArgs.enable-ssl-passthrough="" `
    --set controller.service.externalTrafficPolicy=Local `
    --set controller.ingressClassResource.name="internal-nginx" `
    --set controller.ingressClassResource.controllerValue="k8s.io/internal-ingress-nginx" `
    --set controller.service.public="false" `
    --set controller.publishService.enabled=true `
    --set controller.service.annotations.'service\.beta\.kubernetes\.io/azure-load-balancer-internal'="true" `
    --set controller.service.annotations.'service\.beta\.kubernetes\.io/azure-load-balancer-internal-subnet'="aks-devuat-subnet-api" `
    --set prometheus.create=true `
    --values values.yml


-----------------
# List Services with labels
kubectl get service -l app.kubernetes.io/name=ingress-nginx --namespace ingress-nginx
kubectl get service -l app.kubernetes.io/name=ingress-nginx --namespace ingress-nginx-internal

# List Pods
kubectl get pods -n ingress-nginx
kubectl get pods -n ingress-nginx-internal
kubectl get all -n ingress-nginx
kubectl get all -n ingress-nginx-internal


# Access Public IP
http://<Public-IP-created-for-Ingress>
http://20.92.196.78

# Output should be
404 Not Found from Nginx

# Verify Load Balancer on Azure Mgmt Console
Primarily refer Settings -> Frontend IP Configuration
```

## Step-04: Review Application k8s manifests
- 01-NginxApp1-Deployment.yml
- 02-NginxApp1-ClusterIP-Service.yml
- 03-Ingress-Basic.yml

## Step-05: Deploy Application k8s manifests and verify
```t
# Deploy
kubectl apply -f /99-test/01-Basic-Ingress-Test/

# List Pods
kubectl get pods

# List Services
kubectl get svc

# List Ingress
kubectl get ingress

# Access Application
http://<Public-IP-created-for-Ingress>/app1/index.html
http://<Public-IP-created-for-Ingress>

# Verify Ingress Controller Logs
kubectl get pods -n ingress-nginx
kubectl logs -f <pod-name> -n ingress-nginx
```

## Step-06: Clean-Up Apps
```t
# Delete Apps
kubectl delete -f /99-test/01-Basic-Ingress-Test/
```

------
## Internal Ingress installation
kubectl create namespace ingress-nginx-internal
kubectl annotate namespace ingress-nginx-internal linkerd.io/inject=enabled

openssl genrsa -out tls.key 2048
openssl req -new -key tls.key -out tls.csr
openssl x509 -req -days 3650 -in tls.csr -signkey tls.key -out tls.crt

kubectl create secret generic ingress-nginx-admission --from-file=tls.crt=tls.crt --from-file=tls.key=tls.key -n ingress-nginx-internal

kubectl apply -f nginx-ingress-controller-internal.yml






## Ingress Annotation Reference
- https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/

## Other References
- https://github.com/kubernetes/ingress-nginx
- https://github.com/kubernetes/ingress-nginx/blob/master/charts/ingress-nginx/values.yaml
- https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/cloud/deploy.yaml
- https://kubernetes.github.io/ingress-nginx/deploy/#azure
- https://helm.sh/docs/intro/install/
- https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#ingress-v1-networking-k8s-io
- [Kubernetes Ingress API Reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#ingress-v1-networking-k8s-io)
- [Ingress Path Types](https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types)

## Important Note
```
Ingress Admission Webhooks
With nginx-ingress-controller version 0.25+, the nginx ingress controller pod exposes an endpoint that will integrate with the validatingwebhookconfiguration Kubernetes feature to prevent bad ingress from being added to the cluster. This feature is enabled by default since 0.31.0.
```

```
Create a namespace for your ingress resources
kubectl create namespace ingress-nginx
it does not work when you add injection for this namespace, ingress will not be installed successfully
kubectl annotate namespace ingress-nginx linkerd.io/inject=enabled

To delete the annotation:
kubectl annotate namespace ingress-nginx -n ingress-nginx linkerd.io/inject-
```