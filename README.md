# Kubernetes (K8s) Guide

Kubernetes (often abbreviated as **K8s**) is an open-source container orchestration platform designed to automate the deployment, scaling, management, and networking of containerized applications. Originally developed by Google, it is now maintained by the Cloud Native Computing Foundation ([CNCF](https://www.cncf.io/)).

---

## 🎯 Key Benefits of Kubernetes

- **Automated Bin Packing**: Automatically places containers on nodes based on resource requests and constraints (CPU/Memory).
- **Self-Healing**: Automatically restarts failed containers, replaces/reschedules pods when nodes die, and kills unresponding pods.
- **Service Discovery & Load Balancing**: Exposes pods using DNS names or IP addresses and distributes network traffic evenly.
- **Automated Rollouts & Rollbacks**: Deploys changes incrementally and rolls back instantly if health checks fail.
- **Storage Orchestration**: Automatically mounts storage systems (Local, Cloud Providers like AWS EBS / GCP PD / Azure Disk, NFS).
- **Secret & Configuration Management**: Manages sensitive data (passwords, keys) and app configuration without rebuilding container images.

---

## 🏗️ Kubernetes Architecture

### 1. Control Plane (Master Node)
The Control Plane makes global decisions about the cluster (e.g., scheduling) and detects/responds to cluster events.

| Component | Description |
|---|---|
| **`kube-apiserver`** | Exposes the Kubernetes API (front-end for all cluster communications). |
| **`etcd`** | Consistent and highly-available key-value store for all cluster data. |
| **`kube-scheduler`** | Selects node(s) for newly created pods based on resource availability and constraints. |
| **`kube-controller-manager`** | Runs controller processes (Node Controller, Job Controller, Endpoints Controller, etc.). |

### 2. Worker Nodes
Worker nodes host the running Pods and application workloads.

| Component | Description |
|---|---|
| **`kubelet`** | Primary node agent that ensures containers defined in PodSpecs are running and healthy. |
| **`kube-proxy`** | Maintains network rules on nodes to allow network communication to Pods. |
| **Container Runtime** | Software responsible for running containers (e.g., `containerd`, `CRI-O`). |

---

## 📦 Key Kubernetes Objects

```
┌─────────────────────────────────────────────────────────────┐
│                          Ingress                            │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                          Service                            │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                        Deployment                           │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                           Pod(s)                            │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                     Container(s)                      │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

- **Pod**: The smallest deployable computing unit in K8s (one or more containers sharing storage/network).
- **Deployment**: Declarative update manager for Pods and ReplicaSets (supports rolling updates).
- **StatefulSet**: Manages stateful applications with unique network identities and persistent storage order.
- **Service**: Abstraction defining a logical set of Pods and access policy (`ClusterIP`, `NodePort`, `LoadBalancer`).
- **Ingress**: Manages external HTTP/HTTPS access to services within a cluster.
- **ConfigMap & Secret**: Store non-confidential configuration data and sensitive credentials separately from image definitions.
- **PersistentVolume (PV) & PVC**: Provision and claim persistent storage independently of Pod lifecycles.

---

## 🚀 Repository Helper Scripts & Utilities

This folder includes helper utilities for Kubernetes development:

- **[`kubectl_alias`](file:///Users/vishnu/learning/b_github/z_etc/kubernetes/kubectl_alias)**: Collection of productive shell aliases for `kubectl` (`kgp`, `kgd`, `kgs`, `klf`, `kctx`, `kns`, etc.).
- **[`setup_aliases.sh`](file:///Users/vishnu/learning/b_github/z_etc/kubernetes/setup_aliases.sh)**: Script to permanently enable `kubectl_alias` in your shell profile (`~/.zshrc` / `~/.bashrc`).
- **[`nginx-pod.yaml`](file:///Users/vishnu/learning/b_github/z_etc/kubernetes/nginx-pod.yaml)**: Manifest to create a standard Nginx Pod in Kubernetes.
- **[`argocd-app.yaml`](file:///Users/vishnu/learning/b_github/z_etc/kubernetes/argocd-app.yaml)**: Argo CD `Application` custom resource manifest for automated GitOps deployment.

---

## 🛠️ Quick `kubectl` Cheat Sheet

```bash
# Cluster Info & Nodes
kubectl cluster-info
kubectl get nodes -o wide

# Resource Monitoring
kubectl get pods --all-namespaces
kubectl get svc,deploy,cm,secret

# Pod Inspection & Logs
kubectl describe pod <pod-name>
kubectl logs -f <pod-name>
kubectl exec -it <pod-name> -- /bin/sh

# Applying & Deleting Manifests
kubectl apply -f manifest.yaml
kubectl delete -f manifest.yaml
```
