# Ingress - SSL

## Step-01: 
- Implement SSL using Lets Encrypt
- CertManager position in the architecture below
![Image](/01-cluster/images/uat-arch-01.png)

## Step-02: Install Cert Manager
```t
# Label the cert-manager namespace to disable resource validation
kubectl create namespace cert-manager
kubectl annotate namespace cert-manager linkerd.io/inject=enabled
kubectl label namespace cert-manager cert-manager.io/disable-validation=true

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install cert-manager jetstack/cert-manager `
               --namespace cert-manager `
                --create-namespace `
                --version v1.8.2 `
                --set startupapicheck.timeout=5m `
                --set installCRDs=true `
                --set namespaceLabels.cert-manager.cert-manager.io/disable-validation=true `
                --values values.yml


## SAMPLE OUTPUT
cert-manager v1.8.2 has been deployed successfully!
In order to begin issuing certificates, you will need to set up a ClusterIssuer
or Issuer resource (for example, by creating a 'letsencrypt-staging' issuer).
More information on the different types of issuers and how to configure them
can be found in our documentation:
https://cert-manager.io/docs/configuration/
For information on how to configure cert-manager to automatically provision
Certificates for Ingress resources, take a look at the `ingress-shim`
documentation:
https://cert-manager.io/docs/usage/ingress/


# Verify Cert Manager pods
kubectl get pods --namespace cert-manager -o wide

# Verify Cert Manager Services
kubectl get svc --namespace cert-manager
```

## Step-06: Review or Create Cluster Issuer Kubernetes Manifest
### Review Cluster Issuer Kubernetes Manifest
- Create or Review Cert Manager Cluster Issuer Kubernetes Manigest
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
  namespace: cert-manager
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: fanxwsam@gmail.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt
    solvers:
      - http01:
          ingress:
            class: nginx
```

### Deploy Cluster Issuer
```t
# Deploy Cluster Issuer
kubectl apply --namespace cert-manager -f cluster-issuer.yml

# List Cluster Issuer
kubectl get clusterissuer -n cert-manager

# Describe Cluster Issuer
kubectl describe clusterissuer letsencrypt -n cert-manager
# kubectl describe clusterissuer internal-letsencrypt -n cert-manager
```

## Step-07 Create or Review Linkerd Ingress SSL Kubernetes Manifest in folder '02-Linkerd'
kubectl apply --namespace linkerd-viz -f ../02-Linkerd/ingress-linkerd-web.yml

### Verify Ingress, DNS, CertManager. Access the link below to see if they are working well
linkerd-devuat.samsassets.com


# Verify Cert Manager Pod Logs
kubectl get pods -n cert-manager
kubectl  logs -f <cert-manager-55d65894c7-sx62f> -n cert-manager #Replace Pod name

# Verify SSL Certificates (It should turn to True)
kubectl get certificate -n cert-manager
```
```log
stack@Azure:~$ kubectl get certificate
NAME                      READY   SECRET                    AGE
app1-kubeoncloud-secret   True    app1-kubeoncloud-secret   45m
app2-kubeoncloud-secret   True    app2-kubeoncloud-secret   45m
stack@Azure:~$
```

```log
# Sample Success Log
I0824 13:09:00.495721       1 controller.go:129] cert-manager/controller/orders "msg"="syncing item" "key"="default/app2-kubeoncloud-secret-2792049964-67728538" 
I0824 13:09:00.495900       1 sync.go:102] cert-manager/controller/orders "msg"="Order has already been completed, cleaning up any owned Challenge resources" "resource_kind"="Order" "resource_name"="app2-kubeoncloud-secret-2792049964-67728538" "resource_namespace"="default" 
I0824 13:09:00.496904       1 controller.go:135] cert-manager/controller/orders "msg"="finished processing work item" "key"="default/app2-kubeoncloud-secret-2792049964-67728538
```

## Step-10: Access Application
```t
# URLs
http://sapp1.kubeoncloud.com/app1/index.html
http://sapp2.kubeoncloud.com/app2/index.html
```

## Step-11: Verify Ingress logs for Client IP
```t
# List Pods
kubectl -n ingress-basic get pods

# Check logs
kubectl -n ingress-basic logs -f nginx-ingress-controller-xxxxxxxxx
```
## Step-12: Clean-Up
```t
# Delete Apps
```
kubectl delete -R -f kube-manifests/
```

## Cert Manager
- https://cert-manager.io/docs/installation/#default-static-install
- https://cert-manager.io/docs/installation/helm/
- https://docs.cert-manager.io/
- https://cert-manager.io/docs/installation/helm/#1-add-the-jetstack-helm-repository
- https://cert-manager.io/docs/configuration/
- https://cert-manager.io/docs/tutorials/acme/nginx-ingress/#step-6---configure-a-lets-encrypt-issuer
- https://letsencrypt.org/how-it-works/

  