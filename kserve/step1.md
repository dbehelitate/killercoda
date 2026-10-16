# Step 1: Control Plane Initialization

## Architectural Theory

Traditional model initialization relies on `initContainers` copying data from remote storage into `emptyDir` volumes. Copying gigabytes of data for Large Language Models (LLMs) per Pod replica causes severe node-level I/O bottlenecks and critically increases startup latency. KServe mitigates this anti-pattern through direct OCI image execution.

The KServe control plane requires a certificate manager to enforce mutual TLS for its mutating and validating admission webhooks. KServe extends the Kubernetes API via Custom Resource Definitions (CRDs). 

Furthermore, KServe supports Knative, Standard, and ModelMesh deployment modes. LLM deployments must strictly leverage the Standard mode (plain Kubernetes deployments). Knative's dynamic autoscaling constraints are fundamentally incompatible with statically managed GPU resources and induce unacceptable cold-start latencies.

## Deployment Execution

Execute the following sequence to install the strict prerequisites (`cert-manager`) and deploy the KServe core infrastructure. The `wait` directives ensure the mutating webhooks are fully registered and operational before the cluster accepts subsequent resources.

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml
kubectl wait --for=condition=available --timeout=600s deployment/cert-manager-webhook -n cert-manager

kubectl apply -k "https://github.com/kserve/kserve/config/default?ref=v0.13.0"
kubectl wait --for=condition=available --timeout=600s deployment/kserve-controller-manager -n kserve
```{{exec}}