# Step 1: Control Plane Initialization

## Architectural Theory

Traditional model initialization relies on `initContainers` copying data from remote storage into `emptyDir` volumes.

Copying gigabytes of data for Large Language Models (LLMs) per Pod replica causes severe node-level I/O bottlenecks and critically increases startup latency. 

KServe mitigates this anti-pattern through direct OCI image execution.
  
#### Install KServe 

```bash
  kubectl create namespace kserve
```{{exec}}
  
```bash
# 1. Install cert-manager (prerequisite for KServe webhook certificates)
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true \
  --wait

# 2. Install minimal CRDs
helm install kserve-crd oci://ghcr.io/kserve/charts/kserve-crd-minimal \
  --version v0.20.0 \
  --namespace kserve \
  --create-namespace

# 3. Install KServe resources in Standard mode
helm install kserve-resources oci://ghcr.io/kserve/charts/kserve-resources \
  --version v0.20.0 \
  --namespace kserve \
  --set kserve.controller.deploymentMode=Standard \
  --wait
```{{exec}}

OLD INstall.
curl -fsSL https://github.com/kserve/kserve/releases/download/v0.20.0/kserve-standard-mode-full-install-with-manifests.sh | bash
  


Now Wait --timeout=60 seconds for safety of killercoda playgound



