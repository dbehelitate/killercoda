# Step 6: InferenceService Abstraction and Native Volumes
**FROM STEP 1** 
KServe abstracts this complexity through its core storage initializer controller. 
When a deployment manifest specifies an `oci://` storage URI schema, KServe intercepts the admission request. By enabling the `enableModelcar` parameter within KServe's global configuration (`inferenceservice-config`), the system's mutating admission webhook dynamically transforms the Pod specification at runtime. It automatically injects the shared `emptyDir` memory spaces, provisions the modelcar sidecar container, and appends the requisite symbolic linking logic (`ln -s /proc/...`) without requiring manual operator intervention.
## Architectural Theory

Define the `InferenceService` utilizing the Standard deployment mode and the `oci://` URI scheme. The KServe mutating webhook automatically parses the `storageUri`, injects the required `emptyDir` volume, configures process namespace sharing, and attaches the modelcar sidecar. Aggressive vLLM resource limits and runtime parameters are passed directly to the container specifications to prevent node memory exhaustion.

The modelcar paradigm serves exclusively as a transitional bridge technology. Kubernetes 1.31 introduced native OCI Image Volume Mounts (advanced to beta in Kubernetes 1.35), which permit the Container Runtime Interface (CRI) to mount images directly as local volumes. This native implementation deprecates the necessity for process namespace sharing, VFS traversal hacks, and sidecar execution. Structuring model assets inside the `/models` directory maintains forward compatibility for a seamless migration to native volume mounts.

## Deployment Execution

Write and apply the `InferenceService` manifest to orchestrate the OCI-backed model execution through the KServe control plane.

```bash
cat << 'EOF_YAML' > inferenceservice.yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: smollm-modelcar
  annotations:
    serving.kserve.io/deploymentMode: Standard
spec:
  predictor:
    model:
      modelFormat:
        name: pytorch
      runtime: vllm
      storageUri: "oci://docker.io/library/modelcar-tiny-gguf:latest"
      containers:
      - env:
        - name: VLLM_TARGET_DEVICE
          value: "cpu"
        args:
        - "--model=/mnt/models/models/model.gguf"
        - "--max-model-len=128"
        - "--enforce-eager"
        resources:
          limits:
            cpu: "1"
            memory: "2Gi"
          requests:
            cpu: "500m"
            memory: "1Gi"
EOF_YAML

kubectl apply -f inferenceservice.yaml
```{{exec}}

kubectl apply -f inferenceservice.yaml
```{{exec}}
