**Important Notice**<br>
Database clusters are resource-consuming. <br>
Currently we have 9 database clusters and the basic system requirement of each cluster is 2 vCPUs, and 4 vCPUs would be better.<br>
When we initialize the database cluter with Stackgres Postgres Operator, new kubernetes nodes will be created for the resource allocation.<br>
Sometimes, AKS cannot sacle up the nodes correctly even we have set the node pool stategy is 'Auto Scaling', the backend error looks like this when deploying database cluster,
```
Warning  FailedScheduling   46s   default-scheduler   0/2 nodes are available: 2 Insufficient cpu. preemption: 0/2 nodes are available: 2 No preemption victims found for incoming pod.
  Normal   NotTriggerScaleUp  38s   cluster-autoscaler  pod didn't trigger scale-up: 1 in backoff after failed scale-up
```
To solve this problem, we can scale up the nodes **manually** in AZURE portal, and then install the database cluster.


## Create the namespace asset-postgres-devuat
```
kubectl create namespace asset-postgres-devuat
```

## Database cluster configurations
```
cd D:\workdoc\azure\aks-infinity-env\uat\service\02-Postgres-Stackgres-Cluster
kubectl apply -f 01-sg-instance-profile.yml
kubectl apply -f 02-backup-bucket-secret.yml
kubectl apply -f 03-backup-config.yml
kubectl apply -f 04-postgres-14-config.yml
```

## API-Users
```
kubectl delete secret api-users-database-user -n asset-postgres-devuat
```

```
kubectl create secret generic api-users-database-user `
-n asset-postgres-devuat `
--from-literal=create-user-uat.sql="CREATE USER apiusersuseruat WITH PASSWORD 'apiusersuseruat@123'" `
--from-literal=usernameuat="apiusersuseruat" `
--from-literal=passworduat="apiusersuseruat@123" `
--from-literal=create-user-dev.sql="CREATE USER apiusersuserdev WITH PASSWORD 'apiusersuserdev@123'" `
--from-literal=usernamedev="apiusersuserdev" `
--from-literal=passworddev="apiusersuserdev@123" 
```

```
kubectl delete configmap api-users-database-init -n asset-postgres-devuat
```

```
kubectl create configmap api-users-database-init -n asset-postgres-devuat `
--from-file=complete-generated-database-users.sql
```

Create the database access secret for the user api service in namespace 'asset-api-uat'
```
kubectl create secret generic api-users-postgres `
-n asset-api-uat `
--from-literal=password="apiusersuseruat@123"
```

Create the database access secret for the user api service in namespace 'asset-api-dev'
```
kubectl create secret generic api-users-postgres `
-n asset-api-dev `
--from-literal=password="apiusersuserdev@123"
```



api-user database cluster setup
```
cd aks-infinity-env\poc\service\01-Postgres-Stackgres-Cluster\api-users
kubectl apply -f 01-api-users-pooler.yml
kubectl apply -f 02-sg-scripts.yml
kubectl apply -f 03-api-users-sgcluster.yml
```

Connect to the database using command,
```
kubectl -n asset-postgres-devuat exec -ti api-users-0 -c postgres-util -- psql

select * from pg_user;
```

To create other database cluster, please go to the corresponding folder to run the similar command like above.










