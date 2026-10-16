# Step 5: KServe Storage Initializer Configuration

## Architectural Theory

Manually orchestrating container sidecars and process namespaces across hundreds of production workloads is unmaintainable. KServe abstracts this complexity through its core storage initializer controller. 

When a deployment manifest specifies an `oci://` storage URI schema, KServe intercepts the admission request. By enabling the `enableModelcar` parameter within KServe's global configuration (`inferenceservice-config`), the system's mutating admission webhook dynamically transforms the Pod specification at runtime. It automatically injects the shared `emptyDir` memory spaces, provisions the modelcar sidecar container, and appends the requisite symbolic linking logic (`ln -s /proc/...`) without requiring manual operator intervention.

## Deployment Execution

Apply the configuration patch using standard JSON manipulation via `jq` to enable modelcar behavior in KServe's storage initializer, then roll out the controller manager to synchronize the updated configuration state.

```bash
kubectl get configmap inferenceservice-config -n kserve -o json | \
jq '.data.storageInitializer |= (fromjson | .enableModelcar = true | tojson)' | \
kubectl apply -f -

kubectl rollout restart deployment/kserve-controller-manager -n kserve
kubectl rollout status deployment/kserve-controller-manager -n kserve
```{{exec}}