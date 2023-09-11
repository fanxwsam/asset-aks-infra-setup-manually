# Kubernetes ExternalDNS to create Record Sets in Azure DNS from AKS

## Step-01: 
- Create External DNS Manifest
- Provide Access to DNZ Zones using **Azure Managed Service Identity** for External DNS pod to create **Record Sets** in Azure DNS Zones
- Position of External DNS Component
  ![Image](/01-cluster/images/uat-arch-01.png)

## Step-02: Create External DNS Manifests
- External-DNS needs permissions to Azure DNS to modify (Add, Update, Delete DNS Record Sets)
- There are two ways in Azure to provide permissions to External-DNS pod 
  - Using Azure Service Principal
  - Using Azure Managed Service Identity (MSI)
- We are going to use `MSI` for providing necessary permissions here which is latest and greatest in Azure. 


### Gather Information Required for azure.json file
```t
# To get Azure Tenant ID
az account show --query "tenantId"
"0a0ba87d-f284-4664-b53e-a0a236095ad4"

# To get Azure Subscription ID
az account show --query "id"
"e914d343-0ff7-4739-88f2-0c7a2cbdf765"
```

### Create azure.json file
```json
{
  "tenantId": "0a0ba87d-f284-4664-b53e-a0a236095ad4",
  "subscriptionId": "e914d343-0ff7-4739-88f2-0c7a2cbdf765",
  "resourceGroup": "dns-zone",                    
  "useManagedIdentityExtension": true,  
  "userAssignedIdentityID": "45496ff4-d81c-4c40-a5ad-0339c0aa26d5"
}
```
### the value of "userAssignedIdentityID" above will be replaced in the following steps


## Step-03: Create MSI - Managed Service Identity for External DNS to access Azure DNS Zones

### Create Manged Service Identity (MSI)
- Go to All Services -> Managed Identities -> Add
- Resource Name: aks-devuat-externaldns-access-to-public-dnszones
- Subscription: Aure subscription 1
- Resource group: aks-devuat-rg
- Location: Australia East
- Click on **Create**

### Add Azure Role Assignment in MSI
- Open MSI -> aks-devuat-externaldns-access-to-public-dnszones
- Click on **Azure Role Assignments** -> **Add role assignment**
- Scope: Resource group
- Subscription: Aure subscription 1
- Resource group: dns-zone
- Role: Contributor

### Make a note of Client Id and update in azure.json
- Go to **Overview** -> Make a note of **Client ID"
- Update in **azure.json** value of **userAssignedIdentityID**
```
  "userAssignedIdentityID": "721dfea5-1918-483a-8c6a-f42043ade7c0"
```

## Step-04-1: Associate MSI in AKS Cluster VMSS
- Go to All Services -> Virtual Machine Scale Sets (VMSS) -> Open akspoc related VMSS (aks-systempool-14317293-vmss, aks-dbclupool-39779212-vmss, aks-apipool-19880680-vmss)
- Go to Settings -> Identity -> User assigned -> Add -> aks-devuat-externaldns-access-to-public-dnszones

## Step-04-2: Associate MSI in AKS Cluster VMSS
Do the same thing to MSI 'aks-devuat-externaldns-access-to-private-dnszones'

## Step-05: Create Kubernetes Secret and Deploy ExternalDNS
```t
# Create Secret
cd D:\workdoc\azure\aks-infinity-env\uat\cluster\05-ExternalDNS-for-AzureDNS-on-AKS
kubectl create secret generic azure-config-file --from-file=/public/azure.json --namespace=kube-system

kubectl create secret generic azure-config-file-private --from-file=/private/azure.json --namespace=kube-system

# List Secrets
kubectl get secrets --namespace=kube-system

# !!! important: Change 'ClusterRoleBinding' in file 'external-dns.yml' to the namespace that external dns will stay
default -> whatever you will use
Here, we will use kube-system, so we need to change it to 'kube-system' from 'default'


# Deploy ExternalDNS
kubectl apply -f external-dns-role.yml --namespace=kube-system
kubectl apply -f external-dns-public.yml --namespace=kube-system
kubectl apply -f external-dns-private.yml --namespace=kube-system

# Verify ExternalDNS Logs
kubectl logs -f $(kubectl get po | egrep -o 'external-dns[A-Za-z0-9-]+') -n kube-system
```

```log

# Error Type: 403
Notes: Error 403 will come when our Managed Service Identity dont have access to respective destination resource 

# When all good, we should get log as below
[     0.002561s]  INFO ThreadId(01) linkerd2_proxy: Local identity is external-dns.ingress-nginx.serviceaccount.identity.linkerd.cluster.local
[     0.002563s]  INFO ThreadId(01) linkerd2_proxy: Identity verified via linkerd-identity-headless.linkerd.svc.cluster.local:8080 (linkerd-identity.linkerd.serviceaccount.identity.linkerd.cluster.local)
[     0.002566s]  INFO ThreadId(01) linkerd2_proxy: Destinations resolved via linkerd-dst-headless.linkerd.svc.cluster.local:8086 (linkerd-destination.linkerd.serviceaccount.identity.linkerd.cluster.local)
[     0.062183s]  INFO ThreadId(02) daemon:identity: linkerd_app: Certified identity id=external-dns.ingress-nginx.serviceaccount.identity.linkerd.cluster.local
```



## References
- https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md
- Open Issue and Break fix: https://github.com/kubernetes-sigs/external-dns/issues/1548
- https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx#configuration
- https://github.com/kubernetes/ingress-nginx/blob/master/charts/ingress-nginx/values.yaml
- https://kubernetes.github.io/ingress-nginx/

## External DNS References
- https://github.com/kubernetes-sigs/external-dns
- https://github.com/kubernetes-sigs/external-dns/blob/master/docs/faq.md