# Metrics and Dashboard
Deploy the metrics server. Download the yaml file components.yaml, Open the components.yaml file in a text editor and add the following flag to the args section of the metrics-server container: 
```
- --kubelet-insecure-tls
```

Add resources limits to file components.yaml based on the resources request which will cause the issue :
<br>spec.template.spec.containers[0].resources.requests: Invalid value: "100m": must be less than or equal to cpu limit
<br>spec.template.spec.containers[0].resources.requests: Invalid value: "200Mi": must be less than or equal to memory limit
<br>As below,
```
      containers:
      - args:
        resources:
          limits:
            cpu: 100m
            memory: 200Mi
```


```
kubectl apply -f components.yml
```

Check on the metrics server deployment:
```
kubectl get deployment metrics-server -n kube-system
```

Deploy the Dashboard:
```
# download the file form link below
https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml

Change the nodeSelector: add 'app: system-apps'

kubectl apply -f recommended.yml
```

Create RBAC to control what metrics can be visible
[aks-admin-service-account.yaml](aks-admin-service-account.yaml)
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aks-admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: aks-admin
roleRef:  
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin # this is the cluster admin role
subjects:
- kind: ServiceAccount
  name: aks-admin
  namespace: kube-system
```

Apply
```
kubectl apply -f aks-admin-service-account.yml
```

In Kubernetes 1.24, ServiceAccount token secrets are no longer automatically generated. The LegacyServiceAccountTokenNoAutoGeneration feature gate is beta, and enabled by default. When enabled, Secret API objects containing service account tokens are no longer auto-generated for every ServiceAccount. Use the TokenRequest API to acquire service account tokens, or if a non-expiring token is required, create a Secret API object for the token controller to populate with a service account token.
This means, in Kubernetes 1.24, you need to manually create the Secret; the token key in the data field will be automatically set for you.
```
apiVersion: v1
kind: Secret
metadata:
  name: aks-admin-token
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: "aks-admin"
type: kubernetes.io/service-account-token
```
Since we're manually creating the Secret, we know its name is "aks-admin-token" and don't need to look it up in the ServiceAccount object like before.

So, apply,
```
kubectl apply -f aks-admin-service-account-token.yml
```


```
kubectl describe secret aks-admin-token -n kube-system
```

Start the kubectl proxy:
```
kubectl proxy
```

Access the dashboard endpoint: [Dashboard Endpoint](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login),
choose **Token** and paste the token output from the previous command into the **Token** field.

#### Alternatively add a Dashboard Ingress
```
kubectl apply -f service-ingress.yml
```

Access url: cluster.samsasset.com/dashboard
token:
```
eyJhbGciOiJSUzI1NiIsImtpZCI6IkNWVWtSS3c2ckkyMU81cW4taWZEU1pzelNpZGQxV1BkNk15NFV0a1NENUUifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJha3MtYWRtaW4tdG9rZW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiYWtzLWFkbWluIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiOGQ3YWFhMGEtYmQ5ZC00NmE1LWE5YmItMTMxYzY3ODA5MDQ1Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOmFrcy1hZG1pbiJ9.nFlN6aMzWIW9dNvFygDNy9w7m32B-mL0swAMsCNtYVuHo8oaT6dZcn79jjBkJBS5knImWnc-r59Ssd7ZBjTLeRB7RautGGmGeY-KjInT8xVTl3mv-tUsayOFoX25beEcg2AHbuULpaLjPVs4nm6wXWy0f3_zObNj9utRMz_owqr2G_MRlIDGDYsBhV9RsfRVv9rc3-cPP2mXXS-Ba_SC08CWsMBBa4_2aXe_99rb-2qy1FbCVpal0zEe3SWXhpcxUB8KguOHwl-tEB9oPZ_EDu68AsZ8vvPgzmrxdWlUa4XWtOdubGF7MGifsH8tT1Y4e1w6hDxB0JQweL22I643wUZdEPdaIkqH_WbKv_L0TmQrY_tVp-aC89rXFVOodMPCsEQxisFJ1CJfpqqynlWvLOm793Ldo-W3aOc4UbJF4J8i2NcEq80-6yiVl6lWnkCeMm8rHGdBWN_puuMSVnIC46KkZNrL-wQiwEuNM4YpxwVgiAPZbJUl_Oh5weeCj4_Jdl-3ttoYsPeSxpQZo1Ak6OlDYrE19jE_VVnaj67NvVoMfovQHLPY3_JlyGcNUjN6YzGYHOwJmOGXRDCYFiQbMgap2N0p_t-wEuEAbQ94rWtAkV51R56ZHfUO4adfGtx51ueKwz-b946IqCLwT5j0r8VHmA5pD4zYYQgBxcoiFBw
```

-------------------------------------
#### Modify the Kubernetes Dashboard Logout Timer
```
kubectl edit deployment -n kubernetes-dashboard kubernetes-dashboard
```

Add the following to the args section of the container:
```
--token-ttl=42000
```
