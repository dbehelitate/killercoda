# Step 1: Control Plane Initialization

## Architectural Theory

Traditional model initialization relies on `initContainers` copying data from remote storage into `emptyDir` volumes.
Copying gigabytes of data for Large Language Models (LLMs) per Pod replica causes severe node-level I/O bottlenecks and critically increases startup latency. 

KServe mitigates this anti-pattern through direct OCI image execution.

The KServe control plane requires a certificate manager to enforce mutual TLS for its mutating and validating admission webhooks. 

```bash
kubectl create namespace kserve
```{{exec}}

## Deployment Execution

Execute the following sequence to install the strict prerequisites (`cert-manager`) and deploy the KServe core infrastructure. The `wait` directives ensure the mutating webhooks are fully registered and operational before the cluster accepts subsequent resources.

Wait 1 minute for safety of killer coda playgound

```bash
# 1. Install a supported version of cert-manager (v1.15.0 or newer)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.yaml
kubectl wait --for=condition=available --timeout=60s deployment/cert-manager-webhook -n cert-manager

# 2. Install KServe using --server-side
kubectl apply --server-side -k "https://github.com/kserve/kserve/config/default?ref=v0.20.0"
kubectl wait --for=condition=available --timeout=60s deployment/kserve-controller-manager -n kserve

# 3. If removing kube-rbac-proxy is required for your environment:
kubectl patch deployment kserve-controller-manager -n kserve --type='json' -p='[
  {"op": "remove", "path": "/spec/template/spec/containers/1"}
]'
```{{exec}}
