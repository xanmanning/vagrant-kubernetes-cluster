# Kubernetes Cluster on Ubuntu built with Vagrant and Ansible
## Code to Kubernetes in 15 minutes.

### Introduction

I decided to build my own Kubernetes cluster using Vagrant and Ansible as part
of my experiences learning how to Operate a Kubernetes Cluster.

**NOTE, this is not a production cluster!**

### Why?

Whilst learning to administrate Kubernetes with Minikube and KIND is a great
starting point, I wanted to start learning how to provision and administrate a
cluster, in particular a "bare-metal" cluster.

To make things easy, I have used my K3s role to configure this as a Rancher
K3s cluster.

If you are wanting to run your applications on K8s, I would recommend a provider
such as AWS, Azure or GCP - it's a lot easier from an operational point of view.

### What?

To try and get the "bare-metal" experience, Vagrant and Ansible deploys the
following:

  - 3 worker nodes:
    - Ubuntu (Focal)
    - 2 vCPU
    - 2048 MiB Memory
    - RAID 10 for local storage.
  - 3 control node (HA using Embedded Etcd)
  - Rancher k3s
  - Flannel (CNI)
  - MetalLB (Load Balancer)
  - Longhorn (Storage)

### Architecture

The cluster is composed of Kubernetes nodes (3 control plane workers).

This Kubernetes cluster is Rancher K3s running on OpenSUSE with Flannel as the
Container Network Interface (CNI). Storage is local but can be replicated using
Longhorn storage.

![K3s Diagram](images/cluster-diagram.png)

### Requirements

1. Ansible 2.8+
1. Vagrant 2.0+
1. VirtualBox
1. Kubectl
1. A machine that can run 3 VMs comfortably (Core i7 w/ 16GB RAM Recommended):
   1. 3x (2GB Kubernetes Nodes, 2 vCPU)

### Running

To run the cluster, simply do the following:

  1. `./go.sh`

### Deploying a test app

We are going to be deploying Wekan, a Trello-like Kanban board. This will be
composed of the 2 StatefulSets (app tier and database tier) backed by Longhorn
replicated storage.

![wekan app](images/wekan-diagram.png)

#### 0. Set KUBECONFIG to use the Vagrant cluster config

In your current terminal, in the project directory run:

```bash
export KUBECONFIG=config
```

Check that the config works with `kubectl cluster-info`, you should get an
output such as the below:

```text
Kubernetes master is running at https://10.10.9.2:6443
CoreDNS is running at https://10.10.9.2:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://10.10.9.2:6443/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

#### 1. Check the cluster

We need to ensure that all the pods are started for Kubernetes, Flannel,
Metallb and Longhorn are started.

Run: `kubectl get pods -o wide --all-namespaces`

Each pod should appear as Running or Completed

```text
NAMESPACE         NAME                                        READY   STATUS      RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
kube-system       coredns-66c464876b-dhzbc                    1/1     Running     0          76m   10.42.0.8    kube-0   <none>           <none>
kube-system       helm-install-traefik-4jz8f                  0/1     Completed   0          76m   10.42.0.4    kube-0   <none>           <none>
kube-system       metrics-server-7b4f8b595-bkj7b              1/1     Running     0          76m   10.42.0.7    kube-0   <none>           <none>
kube-system       traefik-5dd496474-6lpr4                     1/1     Running     0          70m   10.42.0.15   kube-0   <none>           <none>
kube-system       traefik-5dd496474-kpmxb                     1/1     Running     0          74m   10.42.1.3    kube-2   <none>           <none>
kube-system       traefik-5dd496474-wtqlw                     1/1     Running     0          70m   10.42.2.11   kube-1   <none>           <none>
longhorn-system   csi-attacher-7cb499df6-7w5kz                1/1     Running     0          71m   10.42.2.8    kube-1   <none>           <none>
longhorn-system   csi-attacher-7cb499df6-dl4lr                1/1     Running     0          71m   10.42.1.7    kube-2   <none>           <none>
longhorn-system   csi-attacher-7cb499df6-z4blh                1/1     Running     0          71m   10.42.0.12   kube-0   <none>           <none>
longhorn-system   csi-provisioner-67846b4b55-2hd49            1/1     Running     0          71m   10.42.2.7    kube-1   <none>           <none>
longhorn-system   csi-provisioner-67846b4b55-c8vdr            1/1     Running     0          71m   10.42.2.6    kube-1   <none>           <none>
longhorn-system   csi-provisioner-67846b4b55-qjgcn            1/1     Running     0          71m   10.42.1.8    kube-2   <none>           <none>
longhorn-system   csi-resizer-5cb8df7db9-k2wdz                1/1     Running     0          71m   10.42.0.13   kube-0   <none>           <none>
longhorn-system   csi-resizer-5cb8df7db9-pd6fj                1/1     Running     0          71m   10.42.1.9    kube-2   <none>           <none>
longhorn-system   csi-resizer-5cb8df7db9-zjmqb                1/1     Running     0          71m   10.42.2.9    kube-1   <none>           <none>
longhorn-system   engine-image-ei-ee18f965-2l8x2              1/1     Running     0          74m   10.42.1.4    kube-2   <none>           <none>
longhorn-system   engine-image-ei-ee18f965-6c2c6              1/1     Running     0          74m   10.42.2.3    kube-1   <none>           <none>
longhorn-system   engine-image-ei-ee18f965-gq9dp              1/1     Running     0          74m   10.42.0.9    kube-0   <none>           <none>
longhorn-system   instance-manager-e-002f78c4                 1/1     Running     0          73m   10.42.0.10   kube-0   <none>           <none>
longhorn-system   instance-manager-e-53692e3c                 1/1     Running     0          73m   10.42.2.5    kube-1   <none>           <none>
longhorn-system   instance-manager-e-553a6cee                 1/1     Running     0          74m   10.42.1.5    kube-2   <none>           <none>
longhorn-system   instance-manager-r-1b6ea19b                 1/1     Running     0          74m   10.42.1.6    kube-2   <none>           <none>
longhorn-system   instance-manager-r-22f655c1                 1/1     Running     0          73m   10.42.0.11   kube-0   <none>           <none>
longhorn-system   instance-manager-r-61b2504d                 1/1     Running     0          73m   10.42.2.4    kube-1   <none>           <none>
longhorn-system   longhorn-csi-plugin-94nwj                   2/2     Running     0          71m   10.42.0.14   kube-0   <none>           <none>
longhorn-system   longhorn-csi-plugin-bv7jl                   2/2     Running     0          71m   10.42.1.10   kube-2   <none>           <none>
longhorn-system   longhorn-csi-plugin-pcv6b                   2/2     Running     0          71m   10.42.2.10   kube-1   <none>           <none>
longhorn-system   longhorn-driver-deployer-5b8f57cfcb-mqmfb   1/1     Running     0          76m   10.42.0.3    kube-0   <none>           <none>
longhorn-system   longhorn-manager-ddjdv                      1/1     Running     0          76m   10.42.0.6    kube-0   <none>           <none>
longhorn-system   longhorn-manager-js647                      1/1     Running     0          75m   10.42.2.2    kube-1   <none>           <none>
longhorn-system   longhorn-manager-zfnpb                      1/1     Running     1          75m   10.42.1.2    kube-2   <none>           <none>
longhorn-system   longhorn-ui-68b99bd456-7dsp6                1/1     Running     0          76m   10.42.0.2    kube-0   <none>           <none>
metallb-system    controller-675d6c9976-vdk77                 1/1     Running     0          76m   10.42.0.5    kube-0   <none>           <none>
metallb-system    speaker-6j6pt                               1/1     Running     0          75m   10.10.9.4    kube-2   <none>           <none>
metallb-system    speaker-pf4t8                               1/1     Running     0          76m   10.10.9.2    kube-0   <none>           <none>
metallb-system    speaker-x8bl6                               1/1     Running     0          75m   10.10.9.3    kube-1   <none>           <none>

```

#### 2. Prepare your `/etc/hosts` file

We are using a Traefik ingress controller to access the Wekan application.
The DNS name we are using is http://wekan.kubed/, Traefik will have an IP of
10.10.9.150 as deployed by Metallb, so you will need a line in your /etc/hosts
file as per the below:

```text
$ grep wekan /etc/hosts
10.10.9.150  wekan.kubed
```

#### 3. Deploy the application.

To deploy Wekan, run `kubectl apply -f wekan.yaml`

```text
$ kubectl apply -f wekan.yaml

serviceaccount/wekandb-view created
clusterrolebinding.rbac.authorization.k8s.io/wekandb-view created
statefulset.apps/wekandb created
statefulset.apps/wekan created
service/wekan-svc created
service/wekandb created
ingress.networking.k8s.io/wekan-ingress created
```

The above is happening in the default namespace, to change namespaces you
will need to modify the service account in `wekan.yaml`.

To watch the deployment, run: `kubectl get pods -w -o wide`

#### 4. Test the application

Go to http://wekan.kubed/ and create an account, take a look around and
play.

![Wekan Application](images/wekan.png)
