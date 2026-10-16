## KServe Storage Initializer Configuration

KServe abstracts the namespace and sidecar logic via the `oci://` storage URI scheme[cite: 68]. To utilize this format, the storage initializer configuration must explicitly enable modelcar behavior[cite: 96, 97].

Apply the configuration patch using standard JSON manipulation.

```bash
kubectl get configmap inferenceservice-config -n kserve -o json | \
jq '.data.storageInitializer |= (fromjson | .enableModelcar = true | tojson)' | \
kubectl apply -f -
```

Force a controller restart to apply the updated configuration state.

```bash
kubectl rollout restart deployment/kserve-controller-manager -n kserve
kubectl rollout status deployment/kserve-controller-manager -n kserve
```
