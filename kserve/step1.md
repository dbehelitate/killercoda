# Step 1: Control Plane Initialization

## Architectural Theory

Traditional model initialization relies on `initContainers` copying data from remote storage into `emptyDir` volumes.

Copying gigabytes of data for Large Language Models (LLMs) per Pod replica causes severe node-level I/O bottlenecks and critically increases startup latency. 

KServe mitigates this anti-pattern through direct OCI image execution.
  
#### Install KServe 
  
```bash
  
kubectl create namespace kserve
  
curl -fsSL https://github.com/kserve/kserve/releases/download/v0.20.0/kserve-standard-mode-full-install-with-manifests.sh | bash
  
```{{exec}}



Wait --timeout=60 seconds for safety of killercoda playgound
Optional
  
```bash
# 3. If removing kube-rbac-proxy is required for your environment:
kubectl patch deployment kserve-controller-manager -n kserve --type='json' -p='[
  {"op": "remove", "path": "/spec/template/spec/containers/1"}
]'
```{{exec}}
