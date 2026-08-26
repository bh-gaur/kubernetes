# Kustomize Guide

**Kustomize** is a template-free Kubernetes configuration management tool natively built into `kubectl`. It lets you customize raw, template-free YAML manifests for multiple environments (such as `development`, `staging`, and `production`) without modifying the original base files.

Think of it as:
**`Kustomize = Base Kubernetes YAMLs + Environment Overlays (Patches)`**

---

## 💡 What is Kustomize?

Unlike tools like Helm that use template directives (e.g., `{{ .Values.name }}`), Kustomize operates directly on **pure, valid Kubernetes YAML files**. 

It uses a `kustomization.yaml` file to declaratively specify rules for combining, patching, and generating Kubernetes resources on the fly.

---

## ❓ When to Use Kustomize?

Use Kustomize when:
- You need to deploy the **same application** across multiple environments (`dev`, `staging`, `prod`) with minor differences (replicas, image tags, environment variables, domains).
- You want to keep your manifests as **standard, valid Kubernetes YAML** without template syntax.
- You are using **GitOps tools** like **Argo CD** or **Flux**, which natively support Kustomize paths out of the box.
- You want to dynamically inject labels, annotations, namespaces, image tags, or ConfigMaps without editing manifest files manually.

### ⚔️ Kustomize vs. Helm

| Feature | Kustomize | Helm |
|---|---|---|
| **Approach** | Overlay & Patching (Template-free) | Templating engine (`{{ .Values }}`) |
| **Manifests** | Plain, valid Kubernetes YAML | Go template syntax (`.yaml` + Helm functions) |
| **Tooling** | Built natively into `kubectl` (`kubectl apply -k`) | Requires `helm` CLI |
| **Package Management** | No package repository mechanism | Chart repositories, dependencies, versioning |
| **Best For** | Multi-environment overlays, GitOps pipelines | Distributing reusable third-party apps |

---

## 📁 Standard Directory Structure

A typical Kustomize setup separates common definitions into a `base/` directory and environment overrides into `overlays/`:

```
kustomize-app/
├── base/                       # Common, environment-independent resources
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── kustomization.yaml     # Declares base resources
└── overlays/                   # Environment-specific customizations
    ├── dev/
    │   └── kustomization.yaml # Dev patches, namePrefix, namespace
    └── prod/
        └── kustomization.yaml # Prod patches, replicas, image tags
```

---

## 🛠️ How to Use Kustomize (Step-by-Step)

### Step 1: Define Base Resources (`base/`)

#### 1. `base/deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: nginx:1.25
          ports:
            - containerPort: 80
```

#### 2. `base/kustomization.yaml`
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
```

---

### Step 2: Define Environment Overlay (`overlays/dev/`)

#### `overlays/dev/kustomization.yaml`
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namePrefix: dev-
namespace: dev

# Reference the base directory
resources:
  - ../../base

# Generate ConfigMap dynamically
configMapGenerator:
  - name: app-config
    literals:
      - ENVIRONMENT=development
      - LOG_LEVEL=debug

# Modify image tag dynamically
images:
  - name: nginx
    newTag: 1.25-alpine

# Patch replicas or specific fields
patches:
  - target:
      kind: Deployment
      name: my-app
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 2
```

---

### Step 3: Define Production Overlay (`overlays/prod/`)

#### `overlays/prod/kustomization.yaml`
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namePrefix: prod-
namespace: production

resources:
  - ../../base

configMapGenerator:
  - name: app-config
    literals:
      - ENVIRONMENT=production
      - LOG_LEVEL=error

images:
  - name: nginx
    newTag: 1.25.3

patches:
  - target:
      kind: Deployment
      name: my-app
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 5
```

---

## 🚀 Key Kustomize Directives

- **`resources`**: List of YAML files or relative directory paths (`base`) to include.
- **`namePrefix` / `nameSuffix`**: Prepends/appends a string to all resource names (e.g. `dev-my-app`).
- **`namespace`**: Automatically assigns a namespace to all resources.
- **`commonLabels`**: Adds labels to all resources and selectors.
- **`commonAnnotations`**: Adds annotations across all manifests.
- **`images`**: Overrides container image names, repositories, or tags without touching Deployment YAML.
- **`configMapGenerator` / `secretGenerator`**: Dynamically creates ConfigMaps/Secrets with content hashes for automatic pod rolling restarts on change.
- **`patches`**: Modifies specific fields of target resources using Strategic Merge Patch or JSON 6902 Patch.

---

## 🖥️ Essential Kustomize CLI Commands

### 1. Build / Preview Manifests
Build and view rendered YAML output without applying to the cluster:
```bash
# Preview base manifests
kubectl kustomize base/

# Preview dev environment overlay
kubectl kustomize overlays/dev/

# Preview prod environment overlay
kubectl kustomize overlays/prod/
```

### 2. Apply to Cluster
Deploy customized manifests directly using `-k` (kustomize flag):
```bash
# Deploy dev environment
kubectl apply -k overlays/dev/

# Deploy production environment
kubectl apply -k overlays/prod/
```

### 3. Delete Resources
Delete all resources managed by an overlay:
```bash
kubectl delete -k overlays/dev/
```

