## Control Plane Initialization

Traditional model initialization relies on `initContainers` copying data from remote storage into `emptyDir` volumes[cite: 97, 102]. Copying gigabytes of data for Large Language Models (LLMs) per Pod replica causes severe I/O bottlenecks and increases startup latency[cite: 69, 102]. KServe mitigates this through direct OCI image execution.

Install `cert-manager`, a strict prerequisite for KServe's mutating and validating webhooks[cite: 56].

```bash
kubectl apply -f [https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml](https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml)
kubectl wait --for=condition=available --timeout=600s deployment/cert-manager-webhook -n cert-manager
```

Deploy the KServe v0.13.0 core CRDs and controller manager[cite: 56].

```bash
kubectl apply -k "[https://github.com/kserve/kserve/config/default?ref=v0.13.0](https://github.com/kserve/kserve/config/default?ref=v0.13.0)"
kubectl wait --for=condition=available --timeout=600s deployment/kserve-controller-manager -n kserve
```

KServe supports Knative, Standard, and ModelMesh deployment modes[cite: 56]. LLM deployments must leverage the Standard mode, which utilizes plain Kubernetes deployments, avoiding Knative's dynamic autoscaling constraints that are incompatible with statically managed GPU resources[cite: 57, 60].
