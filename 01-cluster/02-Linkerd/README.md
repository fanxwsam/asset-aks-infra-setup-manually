### On Windows, use powershell with administrator to install Linkerd CLI
```
choco install linkerd2
```

 ### On MAC/UNIX
 ```
 brew install linkerd
```

```
linkerd version
linkerd check --pre
```

###  Update system node pool, add new lable linkerd.io/control-plane-ns=linkerd so that Linkerd will run on system node pool
```
az aks nodepool update `
    --resource-group aks-devuat-rg `
    --cluster-name aks-devuat `
    --name systempool `
    --labels linkerd.io/control-plane-ns=linkerd nodepool-type=system nodepoolos=linux app=system-apps `
    --no-wait  
```

### Install linkerd and linkerd viz
```
linkerd install --set nodeSelector.app=system-apps --crds | kubectl apply -f -
linkerd install --set nodeSelector.app=system-apps | kubectl apply -f -
linkerd check
linkerd viz install > linkerd-viz.yml
# change manifest file linkerd-viz.yml, add "app: system-apps" to existing nodeSelector object
kubectl apply -f .\linkerd-viz.yml

# test Linkerd Viz
linkerd dashboard
```

### After successfully instally Cert Manager, run command below
kubectl apply -f ingress-linkerd-web.yml

### test the dashboard
linkerd-asset.samsasset.com

### Regerence
https://linkerd.io/2.12/getting-started/