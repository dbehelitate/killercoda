# Step 3: Manual Process Namespace Sharing and Sidecars

## Architectural Theory

Kubernetes natively isolates container processes. To achieve zero-copy data sharing, the Pod specification must be forced to share its process namespace (`shareProcessNamespace: true`). 

A minimal sidecar container (modelcar) caches the OCI layer and exposes it via the Linux Virtual File System (VFS). It executes a symbolic link pointing the primary inference runtime (vLLM) directly to the cached weights via the host's `/proc` hierarchy. The vLLM engine parameters are explicitly constrained to prevent KV cache overallocation and avoid Out-Of-Memory (OOM) kernel panics on resource-limited nodes.

## Deployment Execution

Write and apply the manual Pod manifest to validate the underlying Linux kernel primitives before introducing control plane automation.

```bash
cat << 'EOF_YAML' > manual-modelcar-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: vllm-manual-modelcar
spec:
  shareProcessNamespace: true
  containers:
  - name: vllm-server
    image: vllm/vllm-openai:latest
    env:
    - name: VLLM_TARGET_DEVICE
      value: "cpu"
    args:
    - "--model"
    - "/mnt/models"
    - "--served-model-name"
    - "Qwen/Qwen2.5-0.5B-Instruct"
    - "--max-model-len"
    - "128"
    - "--enforce-eager"
    ports:
    - containerPort: 8000
    resources:
      requests:
        cpu: "500m"
        memory: "1Gi"
      limits:
        cpu: "1"
        memory: "2Gi"
    volumeMounts:
    - mountPath: /mnt
      name: model-share
  - name: modelcar
    image: modelcar-qwen:latest
    imagePullPolicy: Never
    args:
    - sh
    - -c
    - ln -s /proc/$$$$/root/models /mnt/models && sleep infinity
    volumeMounts:
    - mountPath: /mnt
      name: model-share
  volumes:
  - name: model-share
    emptyDir: {}
EOF_YAML

kubectl apply -f manual-modelcar-pod.yaml
kubectl wait --for=condition=Ready --timeout=300s pod/vllm-manual-modelcar
```{{exec}}
