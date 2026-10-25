## KServe and Native Volumes

#### The modelcar paradigm: a transitional bridge technology.  

1. Kubernetes 1.35 introduced BETA "OCI Image Volume Mounts" allowing Container Runtime Interface (CRI) to mount images directly as local volumes.  
This deprecates the necessity for process namespace sharing, VFS traversal hacks, and sidecar execution.  
  
2. KServe meanwhile abstracts this complexity through its core storage initializer controller. 
When a deployment`InferenceService`manifest specifies an `oci://` storage URI schema, KServe intercepts the admission request.    

`enableModelcar` within KServe's `inferenceservice-config` transforms the Pod spec at runtime injecting the shared `emptyDir` , provisioning the sidecar container and appending the symbolic link `ln -s /proc/...`   

#### Deployment 

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
```
  
```bash
kubectl apply -f inferenceservice.yaml
```{{exec}}
  
