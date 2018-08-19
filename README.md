# Kubernetes Cluster on CentOS build with Vagrant and Ansible
## Code to Kubernetes in 15 minutes.

### Introduction

I decided to build my own Kubernetes cluster using Vagrant and Ansible as part
of my experiences learning how to Operate a Kubernetes Cluster. As part of that
learning I built a couple of playbooks that I thought were worth sharing.

**NOTE, this is not a production cluster!**

### Why?

I know there are other projects for creating a Kubernetes cluster in Vagrant,
likely a lot better and more usable than mine. I made this so that I can start
to understand how a Kubernetes cluster works and how it fits together.

This is probably what a bare-metal Kubernetes cluster would look like when
deploying, apart from the slow, single point of failure NFS Storage. Like I said
above, this isn't anything like what you'd run in production.

If you want production grade Kubernetes, go use AWS, GCP or Azure.

### Architecture

The cluster is composed of Kubernetes nodes (1 master, 2 workers) and some
NFS storage for Persistent Volumes.

This Kubernetes cluster is running on CentOS 7, with kube-router as the network
layer.

![K8s Diagram](images/cluster-diagram.png)

### Requirements

1. Ansible 2.5+
1. Vagrant 2.0+
1. VirtualBox
1. A machine that can run 4 VMs comfortably (Core i7 w/ 16GB RAM Recommended):
   1. 3x (2GB Kubernetes Nodes, 2 vCPU)
   1. 1x (512MB NFS Fileserver, 1 vCPU)

### Running

To run the cluster, simply run `vagrant up` and wait for the provisioning to
complete.
