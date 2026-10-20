# Step 1: Control Plane Initialization

## Architectural Theory

Traditional model initialization relies on `initContainers` copying data from remote storage into `emptyDir` volumes.

Copying gigabytes of data for Large Language Models (LLMs) per Pod replica causes severe node-level I/O bottlenecks and critically increases startup latency. 

KServe mitigates this anti-pattern through direct OCI image execution.
  
#### Install KServe 

```bash
# 1. Install minimal CRDs
helm install kserve-crd oci://ghcr.io/kserve/charts/kserve-crd-minimal \
  --version v0.20.0 \
  --namespace kserve \
  --create-namespace

# 2. Install KServe resources in Standard mode
helm install kserve-resources oci://ghcr.io/kserve/charts/kserve-resources \
  --version v0.20.0 \
  --namespace kserve \
  --set kserve.controller.deploymentMode=Standard
  ```{{exec}}
  
```bash
  
kubectl create namespace kserve
```{{exec}}


```bash  
curl -fsSL https://github.com/kserve/kserve/releases/download/v0.20.0/kserve-standard-mode-full-install-with-manifests.sh | bash
  
```{{exec}}

Now Wait --timeout=60 seconds for safety of killercoda playgound



