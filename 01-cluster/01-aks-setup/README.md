## Architecture - Components and Their Relationships
![Image](/01-cluster/images/uat-arch-01.png)

## Architecture - Networking
![Image](/01-cluster/images/uat-arch-02.png)


## Step-01: Pre-requisite Items
- Design a Production grade cluster using command line
- az aks cli

### Pre-requisite Items for AKS Cluster Design
- Create Resource Group
- Create Azure Virtual Network
  - Create default Subnet for AKS Nodepools
  - Create separate Subnet for Virtual Nodes (Serverless)
- Create Azure AD User, Group for managing AKS Clusters using Azure AD Users
- Create SSH Keys to enable and access Kubernetes Workernodes via SSH Terminal
- Create Log Analytics Workspace for enabling Monitoring Add On during AKS Cluster creation  
- Set Windows Username and Password during AKS Cluster creation to have AKS Cluster support future Windows Nodepools

## Step-02: Pre-requisite-1: Create Resource Group
```
# Edit export statements to make any changes required as per your environment
# Execute below export statements
$AKS_DEVUAT_RESOURCE_GROUP = "aks-devuat-rg"
$AKS_DEVUAT_REGION = "australiaeast"
echo $AKS_DEVUAT_RESOURCE_GROUP, $AKS_DEVUAT_REGION

# Create Resource Group for the cluster
az group create --location ${AKS_DEVUAT_REGION} `
                --name ${AKS_DEVUAT_RESOURCE_GROUP}

# Create Resource Group for the Jump Box VMs
az group create --location ${AKS_DEVUAT_REGION} `
                --name aks-mgr-rg
# Create the VM (can operate on the Azure Portal or CLI)                
                
```                

## Step-02: Pre-requisite-2: Create Azure Virtual Network and Four Subnets
- Create Azure Virtual Network
- Create Four subnets one for system node pool of AKS Cluster and others for the type 'user' node pools and Azure Virtual Nodes 
  - Subnet-1: aks-devuat-default
  - Subnet-2: aks-devuat-virtual-nodes
  - Subnet-3: aks-devuat-subnet-dbcluster
  - Subnet-4: aks-devuat-subnet-api


```
# Edit export statements to make any changes required as per the cooresponding environment
# Execute below export statements 
$AKS_DEVUAT_VNET = "aks-devuat-vnet"
$AKS_DEVUAT_VNET_ADDRESS_PREFIX = "10.10.0.0/16"
$AKS_DEVUAT_VNET_SUBNET_DEFAULT = "aks-devuat-subnet-default"
$AKS_DEVUAT_VNET_SUBNET_DEFAULT_PREFIX = "10.10.0.0/20"
$AKS_DEVUAT_VNET_SUBNET_API = "aks-devuat-subnet-api"
$AKS_DEVUAT_VNET_SUBNET_API_PREFIX = "10.10.16.0/20"
$AKS_DEVUAT_VNET_SUBNET_DB_CLUSTER = "aks-devuat-subnet-dbcluster"
$AKS_DEVUAT_VNET_SUBNET_DB_CLUSTER_PREFIX = "10.10.32.0/20"
$AKS_DEVUAT_VNET_SUBNET_VIRTUALNODES = "aks-devuat-subnet-virtual-nodes"
$AKS_DEVUAT_VNET_SUBNET_VIRTUALNODES_PREFIX = "10.10.48.0/20"


# Create Virtual Network & default Subnet
az network vnet create -g ${AKS_DEVUAT_RESOURCE_GROUP} `
                       -n ${AKS_DEVUAT_VNET} `
                       --address-prefix ${AKS_DEVUAT_VNET_ADDRESS_PREFIX} `
                       --subnet-name ${AKS_DEVUAT_VNET_SUBNET_DEFAULT} `
                       --subnet-prefix ${AKS_DEVUAT_VNET_SUBNET_DEFAULT_PREFIX} 

# Create Virtual Nodes Subnet in Virtual Network
az network vnet subnet create `
    --resource-group ${AKS_DEVUAT_RESOURCE_GROUP} `
    --vnet-name ${AKS_DEVUAT_VNET} `
    --name ${AKS_DEVUAT_VNET_SUBNET_VIRTUALNODES} `
    --address-prefixes ${AKS_DEVUAT_VNET_SUBNET_VIRTUALNODES_PREFIX}

# Get Virtual Network default subnet id
$AKS_DEVUAT_VNET_SUBNET_DEFAULT_ID = $(az network vnet subnet show `
                           --resource-group ${AKS_DEVUAT_RESOURCE_GROUP} `
                           --vnet-name ${AKS_DEVUAT_VNET} `
                           --name ${AKS_DEVUAT_VNET_SUBNET_DEFAULT} `
                           --query id `
                           -o tsv)
echo ${AKS_DEVUAT_VNET_SUBNET_DEFAULT_ID}

# Create Database Cluster Nodes Subnet in Virtual Network
az network vnet subnet create `
    --resource-group ${AKS_DEVUAT_RESOURCE_GROUP} `
    --vnet-name ${AKS_DEVUAT_VNET} `
    --name ${AKS_DEVUAT_VNET_SUBNET_DB_CLUSTER} `
    --address-prefixes ${AKS_DEVUAT_VNET_SUBNET_DB_CLUSTER_PREFIX}

# Get Virtual Network Database Cluster subnet id
$AKS_DEVUAT_VNET_SUBNET_DB_CLUSTER_ID = $(az network vnet subnet show `
                           --resource-group ${AKS_DEVUAT_RESOURCE_GROUP} `
                           --vnet-name ${AKS_DEVUAT_VNET} `
                           --name ${AKS_DEVUAT_VNET_SUBNET_DB_CLUSTER} `
                           --query id `
                           -o tsv)
echo ${AKS_DEVUAT_VNET_SUBNET_DB_CLUSTER_ID}

# Create APIs' Subnet in Virtual Network
az network vnet subnet create `
    --resource-group ${AKS_DEVUAT_RESOURCE_GROUP} `
    --vnet-name ${AKS_DEVUAT_VNET} `
    --name ${AKS_DEVUAT_VNET_SUBNET_API} `
    --address-prefixes ${AKS_DEVUAT_VNET_SUBNET_API_PREFIX}

# Get Virtual Network Database Cluster subnet id
$AKS_DEVUAT_VNET_SUBNET_API_ID = $(az network vnet subnet show `
                           --resource-group ${AKS_DEVUAT_RESOURCE_GROUP} `
                           --vnet-name ${AKS_DEVUAT_VNET} `
                           --name ${AKS_DEVUAT_VNET_SUBNET_API} `
                           --query id `
                           -o tsv)
echo ${AKS_DEVUAT_VNET_SUBNET_API_ID}


```

## Step-02: Pre-requisite-3: Create Azure AD Group & Admin User
- Create Azure AD Group: aksadmins
- Create Azure AD User: aksadmin1 and associate to aksadmins ad group
```
# Create Azure AD Group
az ad group create --display-name aksadmins --mail-nickname aksadmins --query objectId -o tsv
# **Important Notice** Repalace the group object ID with the real one when you create. due to privillege, we cannot query the ID, please use Azure Portal to get it.
$AKS_AD_AKSADMIN_GROUP_ID= "ec5ecb03-cd9c-4aa7-b8eb-9db476ed5552"
echo $AKS_AD_AKSADMIN_GROUP_ID

# Create Azure AD AKS Admin User 
# Replace with the AD Domain - fanxwsam@gmail.com
# Make sure your operation account have the sufficient privileges to create users. If no, you cannot create a new user.

$AKS_AD_AKSADMIN1_USER_OBJECT_ID = $(az ad user create `
  --display-name "AKS Admin1" `
  --user-principal-name fanxwsam@gmailcom `
  --password @AKSAdmins@123 `
  --query objectId -o tsv)
echo $AKS_AD_AKSADMIN1_USER_OBJECT_ID

# Account fanxwsam@gmail.com has sufficient privileges to add an existing user to the aksadmins group
# After the cluster is created, we can add the existing user to IMA so that the existing user can manage the cluster then
# Replace the member-id with the correct 'ObjectId' of the user
# az ad group member add --group aksadmins --member-id $AKS_AD_AKSADMIN1_USER_OBJECT_ID
# az ad group member add --group aksadmins --member-id 4942a532-6db8-4a60-8cb0-2c717a30db16

# Make a note of Username and Password. Due to the privileges, here we might just use the existing account
# Username: xxxx@xxxx
# Password: xxxx
```


## Step-04: Pre-requisite-4: Create SSH Key
```
# Create Folder
# mkdir $HOME/.ssh/aks-devuat-sshkeys
mkdir $HOME/../../.ssh/aks-devuat-sshkeys

# Create SSH Key
ssh-keygen `
    -m PEM `
    -t rsa `
    -b 4096 `
    -C "azureuser@myserver" `
    -f $HOME/../../.ssh/aks-devuat-sshkeys/aksdevuatsshkey `
    -N mypassphrase

# List Files
ls $HOME/../../.ssh/aks-devuat-sshkeys

# Set SSH KEY Path
$AKS_SSH_KEY_LOCATION = 'C:\.ssh\aks-devuat-sshkeys\aksdevuatsshkey.pub'
echo $AKS_SSH_KEY_LOCATION

```
- Reference for [Create SSH Key](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed)

## Step-05: Pre-requisite-5: Create Log Analytics Workspace
```
# Create Log Analytics Workspace
$AKS_DEVUAT_MONITORING_LOG_ANALYTICS_WORKSPACE_ID = $(az monitor log-analytics workspace create `
                                          --resource-group ${AKS_DEVUAT_RESOURCE_GROUP} `
                                           --workspace-name aksdevuat-loganalytics-workspace1 `
                                           --query id `
                                           -o tsv)
echo $AKS_DEVUAT_MONITORING_LOG_ANALYTICS_WORKSPACE_ID
```

## Step-06: Pre-requisite-5: Get Azure AD Tenant ID and Set Windows Username Passwords
```
# List Kubernetes Versions available as on today
az aks get-versions --location ${AKS_DEVUAT_REGION} -o table

# Get Azure Active Directory (AAD) Tenant ID
$AZURE_DEFAULT_AD_TENANTID = $(az account show --query tenantId --output tsv)
echo $AZURE_DEFAULT_AD_TENANTID
or
Go to Services -> Azure Active Directory -> Properties -> Tenant ID


# Set Windows Server/Node Username & Password
$AKS_WINDOWS_NODE_USERNAME = "azureuser"
$AKS_WINDOWS_NODE_PASSWORD = "P@ssw0rd1234AH1"
echo $AKS_WINDOWS_NODE_USERNAME, $AKS_WINDOWS_NODE_PASSWORD
```

## Step-07: Create Cluster with System Node Pool
```
# Set Cluster Name
$AKS_CLUSTER = "aks-devuat"
echo $AKS_CLUSTER

# Upgrade az CLI  (To latest version)
az --version
az upgrade

# Create AKS cluster, default system node pool size 'Standard_DS2_v2'
az aks create --name ${AKS_CLUSTER} `
              --resource-group ${AKS_DEVUAT_RESOURCE_GROUP} `
              --enable-managed-identity `
              --ssh-key-value ${AKS_SSH_KEY_LOCATION} `
              --admin-username aksnodeadmin `
              --node-count 2 `
              --enable-cluster-autoscaler `
              --min-count 1 `
              --max-count 10 `
              --network-plugin azure `
              --service-cidr 10.10.240.0/20 `
              --dns-service-ip 10.10.240.10 `
              --docker-bridge-address 172.17.0.1/16 `
              --vnet-subnet-id ${AKS_DEVUAT_VNET_SUBNET_DEFAULT_ID} `
              --enable-aad `
              --aad-admin-group-object-ids ${AKS_AD_AKSADMIN_GROUP_ID} `
              --aad-tenant-id ${AZURE_DEFAULT_AD_TENANTID} `
              --windows-admin-password ${AKS_WINDOWS_NODE_PASSWORD} `
              --windows-admin-username ${AKS_WINDOWS_NODE_USERNAME} `
              --node-osdisk-size 30 `
              --node-vm-size Standard_DS2_v2 `
              --nodepool-labels nodepool-type=system nodepoolos=linux app=system-apps `
              --nodepool-name systempool `
              --nodepool-tags nodepool-type=system nodepoolos=linux app=system-apps `
              --enable-addons monitoring `
              --workspace-resource-id ${AKS_DEVUAT_MONITORING_LOG_ANALYTICS_WORKSPACE_ID} `
              --enable-ahub `
              --zones 1, 2

az aks nodepool show -g ${AKS_DEVUAT_RESOURCE_GROUP} --cluster-name ${AKS_CLUSTER} -n systempool

az aks get-credentials --resource-group ${AKS_DEVUAT_RESOURCE_GROUP} --name ${AKS_CLUSTER} --admin

# RBAC is enabled on the AKS cluster, and the default RBAC configuration may not include the necessary permissions for you to access the environment even yourself create the AKS cluster. 
# Create a new ClusterRoleBinding that grants the user accounts the necessary permissions to access the pods. 
# Here's an example command that creates a ClusterRoleBinding that grants the "cluster-admin" role to fanxwsam@gmail.com and pheobewong183@gmail.com

kubectl create clusterrolebinding cluster-admin-binding-1 --clusterrole=cluster-admin --user=fanxwsam@gmail.com


- **Important Note-1:** For creating and using the own VNet, static IP address, or attached Azure disk where the resources are outside of the worker node resource group, use the PrincipalID of the cluster System Assigned Managed Identity to perform a role assignment. For more information on role assignment
- **Important Note-2:** Permission grants to cluster Managed Identity used by Azure Cloud provider may take up 
60 minutes to populate.
- Although this is optional and not needed for us, I also met the 'permission issue', so this is not only required when our AKS VNET and AKS Worker Nodes both are in the same resource groups, it also happens when we create an AKS cluster with specific vnet and enabled CNI feature.

# Get VNET ID
$AKS_DEVUAT_VNET_ID = $(az network vnet show --resource-group ${AKS_DEVUAT_RESOURCE_GROUP} `
                     --name ${AKS_DEVUAT_VNET} `
                     --query id `
                     -o tsv)
echo $AKS_DEVUAT_VNET_ID

# Get principal
$spID=$(az aks show -g ${AKS_DEVUAT_RESOURCE_GROUP} -n ${AKS_CLUSTER} --query "identity.principalId" -o tsv)
echo $spID $AKS_DEVUAT_VNET_ID
az role assignment create --assignee $spID `
                          --scope $AKS_DEVUAT_VNET_ID `
                          --role Contributor
```

## Step-08: Create Database Cluster Node Pool and Associate to the Corresponding Subnet
```
# Create Database Cluster Node Pool in Subnet 'aks-devuat-subnet-dbcluster'
$AKS_DEVUAT_DATABASE_CLUSTER_POOL = "dbclupool"
az aks nodepool add --cluster-name ${AKS_CLUSTER} `
                    --name ${AKS_DEVUAT_DATABASE_CLUSTER_POOL} `
                    --resource-group ${AKS_DEVUAT_RESOURCE_GROUP} `
                    --node-count 2 `
                    --enable-cluster-autoscaler `
                    --min-count 1 `
                    --max-count 10 `
                    --node-osdisk-size 30 `
                    --node-osdisk-type Ephemeral `
                    --node-vm-size Standard_D4s_v3 `
                    --mode User `
                    --os-sku Ubuntu `
                    --os-type Linux `
                    --max-pods 100 `
                    --labels nodepool-type=user nodepoolos=linux app=dbcluster-apps `
                    --tags  nodepool-type=user nodepoolos=linux app=dbcluster-apps `
                    --vnet-subnet-id ${AKS_DEVUAT_VNET_SUBNET_DB_CLUSTER_ID} `
                    --zones 1, 2

az aks nodepool show -g ${AKS_DEVUAT_RESOURCE_GROUP} --cluster-name ${AKS_CLUSTER} -n ${AKS_DEVUAT_DATABASE_CLUSTER_POOL}

```


## Step-09: Create Node Pool for APIs and Associate to the Corresponding Subnet
```
# Create API Node Pool in Subnet 'aks-devuat-subnet-api'
$AKS_DEVUAT_API_NODE_POOL = "apipool"

az aks nodepool add --cluster-name ${AKS_CLUSTER} `
                    --name ${AKS_DEVUAT_API_NODE_POOL} `
                    --resource-group ${AKS_DEVUAT_RESOURCE_GROUP} `
                    --node-count 1 `
                    --enable-cluster-autoscaler `
                    --min-count 1 `
                    --max-count 10 `
                    --node-osdisk-size 30 `
                    --node-osdisk-type Ephemeral `
                    --node-vm-size Standard_D4s_v3 `
                    --mode User `
                    --os-sku Ubuntu `
                    --os-type Linux `
                    --max-pods 100 `
                    --labels nodepool-type=user nodepoolos=linux app=api-apps `
                    --tags  nodepool-type=user nodepoolos=linux app=api-apps `
                    --vnet-subnet-id ${AKS_DEVUAT_VNET_SUBNET_API_ID} `
                    --zones 1, 2


az aks nodepool show -g ${AKS_DEVUAT_RESOURCE_GROUP} --cluster-name ${AKS_CLUSTER} -n ${AKS_DEVUAT_API_NODE_POOL}

```

References:
- https://learn.microsoft.com/en-us/training/modules/aks-network-design-azure-container-network-interface/?source=recommendations
- https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-network
- https://learn.microsoft.com/en-us/azure/aks/concepts-network
- https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni
- https://learn.microsoft.com/en-us/azure/aks/concepts-clusters-workloads#node-selectors

------------------
<BR>
<BR>

## Step-10 (OPTIONAL): Enable Virtual Nodes on our AKS Cluster
Optional for the Virtal Nodes - might be used for serverless applications in the future.
Virtual nodes are typically used for running specialized workloads or for scaling up capacity quickly during periods of high demand. These workloads may have different resource requirements than the workloads running on traditional nodes, and the virtual nodes provide a way to run them in an isolated environment without affecting the other pods running on traditional nodes.
It's important to note that all the pods running in an AKS cluster share the same network and storage resources, regardless of whether they are running on virtual nodes or traditional nodes. 
Therefore, it's important to design the cluster architecture in a way that avoids resource contention and ensures that each pod has the necessary resources to run effectively.

So, we just simply enable the feature of Virtal Nodes, just in case we might use it in the future.

### Step-10-01: Enable Virtual Nodes Add-On on our AKS Cluster

```
# Verify Environment Variables
echo ${AKS_DEVUAT_RESOURCE_GROUP} ${AKS_CLUSTER} ${AKS_DEVUAT_VNET_SUBNET_VIRTUALNODES}

# Enable Virtual Nodes on AKS Cluster

az aks enable-addons `
    --resource-group ${AKS_DEVUAT_RESOURCE_GROUP} `
    --name ${AKS_CLUSTER} `
    --addons virtual-node `
    --subnet-name ${AKS_DEVUAT_VNET_SUBNET_VIRTUALNODES}


# List Nodes
kubectl get nodes

# List Virtual Nodes ACI Pods
kubectl get pods -n kube-system

# List Nodes
kubectl get nodes   

# List Virtual Nodes ACI Pods
kubectl get pods -n kube-system

# Sample Output for Reference
NAME                                         READY   STATUS             RESTARTS   AGE
aci-connector-linux-6d57ccbf8b-bj6rk         0/1     CrashLoopBackOff   8          17m
azure-cni-networkmonitor-pmbvh               1/1     Running            0          33m
azure-ip-masq-agent-rjvbd                    1/1     Running            0          33m


# Verify Logs ACI Connector
kubectl get pods -n kube-system
kubectl -n kube-system logs -f $(kubectl get po -n kube-system | egrep -o 'aci-connector-linux-[A-Za-z0-9-]+')
```
### Step-10-02: Fix ACI Connector CrashLoopBackOff Issue
- Go to Services -> Managed Identities -> aciconnectorlinux-aksprod1 
- Azure Role Assignments
    - Add Role Assignment
    - Scope: Resource Group
    - Subscription: Azure subscription 1
    - Resource Group: aks-devuat
    - Role: Contributor
- Click on **SAVE**

### Step-10-03: Delete ACI Connector Pod to recreate it 
```
# List Pods
kubectl get pods -n kube-system

# Delete aci-connector-linux pod to recreate it
kubectl -n kube-system delete pod <ACI-Connector-Pod-Name>

# List Pods (ACI Connector Pod should be running)
kubectl get pods -n kube-system
```

### Step-10-04: List Virtual Nodes and See if listed
```
# List Nodes
kubectl get nodes

# Sample Output
NAME                                 STATUS   ROLES   AGE    VERSION
aks-dbclupool-16999912-vmss000001    Ready    agent   46h    v1.24.9
aks-systempool-35957937-vmss000000   Ready    agent   3d7h   v1.24.9
virtual-node-aci-linux               Ready    agent   32m    v1.19.10-vk-azure-aci-1.4.8

# List Nodes using Labels
kubectl get nodes -o wide -l nodepoolos=linux
kubectl get nodes -o wide -l app=user-apps
```

----------
## assign role "Azure Kubernetes Service Cluster User Role" to group 'aksadmins', scope is the cluster 'XXXX'
```
az role assignment create `
  --assignee 4942a532-6db8-4a60-8cb0-2c717a30db16 `
  --role "Azure Kubernetes Service Cluster User Role" `
  --scope "/subscriptions/e914d343-0ff7-4739-88f2-0c7a2cbdf765/resourcegroups/aks-devuat-rg/providers/Microsoft.ContainerService/managedClusters/aks-devuat"
```

---------

