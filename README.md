#### Encode and compress the Sitecore license

```
cd k8s
```
```
.\1.EncodeAndCompressLicense.ps1 -path <Sitecore License Path>
```

Go to **secrets\sitecore-license.txt** to see the license is encoded and compressed.

> Sitecore Kubernetes deployments use Secrets to securely store the strings the containers in the
cluster use. The Secrets are used to store database user names, passwords, and TLS certificates. You must deploy the Secrets to the K8s cluster before you deploy any Sitecore containers.

#### General SSL certificates

```
Start-Process .\2.GenerateSSLCertificates.bat 
```

The generated SSL certificates will be added to **secrets\tls**.

#### Generate Sitecore identity token

```
.\3.GenerateSitecoreIdentityToken.ps1
```

Find the **SitecoreIdentityTokenSigning.pfx** and the new secret added to **secrets\sitecore-identitycertificate.txt** file.

#### Login AZ CLI

```
.\4.LoginAZ.ps1
```

This will open a new browser so you can log in with your Azure account.

#### Create resource group and container registry

```
.\5.CreateResourceGroupAndContainerRegistry.ps1 -region australiaeast -resourcegroup sckrg -myregistry sckacr1 -skuacr standard
```

This commands Azure CLI to create a new resource group with the name **sckrg** in **AustraliaEast** region and add a new Azure container registry with the name **sckacr1** to this resource group.

#### Create AKS

Next, we will provision a new AKS with the name **sckaks1** to the **sckrg** resource group and link it with the ACR created in the previous step: 

```
.\6.CreateAKS.ps1 -region australiaeast -resourcegroup sckrg -aksname sckaks1 -acrname sckacr1 -azurewindowspassword Password!12345
```

#### Install Helm and Kubectl

```
.\7.InstallHelmAndKubectl.ps1 -region australiaeast -resourcegroup sckrg -aksname sckaks1 -acrname sckacr1
```

This commands PowerShell to download **helm.exe** and **kubectl.exe** to the k8s folder so they will be used to deploy NGINX and other services in the next steps.

#### Create NGINX ingress controller

```
.\8.CreateNginx.ps1
```

> An ingress controller acts as a reverse proxy and load balancer. It implements a Kubernetes Ingress. The ingress controller adds a layer of abstraction to traffic routing, accepting traffic from outside the Kubernetes platform and load balancing it to Pods running inside the platform.

Check out what rules are specified for cm, cd and id in the **ingress-nginx\ingress.yaml** file.

#### Deploy secrets

```
.\9.CreateSecrets.ps1
```

Secrets can be viewed in **AKS > Configuration > Secrets** in the Azure portal

#### Deploy externals

```
.\10.DeployExternals.ps1
```

This commands the Azure CLI to deploy the external services specified in the **kustomization.yaml** file in the **./external** folder. Refer to the **Installation Guide for Production Environment with Kubernetes** to learn more about the Kubernetes specification files.

#### Init Solr and MSSQL

```
.\11.InitSolrAndMSSQL.ps1
```

#### Deploy Sitecore solutions (CM, CD, ID)

```
.\12.DeploySitecore.ps1
``` 

You can find the specification for these services in cm.yaml, cd.yaml and id.yaml and notice how they specify Sitecore images to be pulled from the **sitecore-docker-registry**: 

```
      imagePullSecrets:
      - name: sitecore-docker-registry
```

#### Add hosts entries

One last thing to do before we can launch the new website from our local is to add hosts entries to the hosts file in our machine but first, you need to get the external IP from the load balancer (NGINX) by running this command:

```
.\kubectl get ingress
```

Then, use the IP address to add these entries to your hosts file: 

```
<some IP>  cm.globalhost
<some IP>  id.globalhost
<some IP>  cd.globalhost
```

#### Launch the sites

- **CD:** [https://cd.globalhost](https://cd.globalhost)
- **CM:** [https://cm.globalhost/sitecore](https://cm.globalhost/sitecore)

To log in as the admin, enter admin:b. The password can be changed in your secret: **sitecore-adminpassword**.

#### Stop and restart an existing cluster (Optional)

```
az aks stop --name sckaks1 --resource-group sckrg
```

```
# Start the AKS cluster
az aks start --name sckaks1 --resource-group sckrg

# Delete the existing SQL and Solr init jobs
.\kubectl delete job mssql-init
.\kubectl delete job solr-init 

# Deploy SQL and Solr init jobs
.\kubectl apply -f ./init/
```

## Bonus

#### Get namespaces
```
kubectl get namespaces
```

#### Get deployment statuses
```
kubectl get deployments
```

#### Get services
```
kubectl get svc
```

#### Get pods
```
kubectl get pods
```

#### Describe service
```
kubectl describe nodes|pods <node or pod name>
```

#### Create resources from a manifest file from a directory
```
kubectl apply -f ./dir
```