1. Azure does not support creating subnet in a specific "Availability zone".
   https://blog.ipspace.net/2021/02/public-cloud-regions-availability-zones.html
   https://blog.ipspace.net/2021/02/vpc-subnets-aws-azure-gcp.html

   ![Image](../poc/cluster/images/aws-vpc.png)
   ![Image](../poc/cluster/images/azure-vnet.png)


Use network policies to allow or deny traffic to pods. By default, all traffic is allowed between pods within a cluster. For improved security, define rules that limit pod communication.
Network policy should only be used for Linux-based nodes and pods in AKS.

To use network policy, enable the feature when you create a new AKS cluster. You can't enable network policy on an existing AKS cluster. Plan ahead to enable network policy on the necessary clusters.

### Important Notice
When create the cluster, enable the feature 'Network Policy'