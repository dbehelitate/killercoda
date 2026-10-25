## KServe and Native Volumes

#### The modelcar paradigm: a transitional bridge technology.  

1. Kubernetes 1.35 introduced BETA "OCI Image Volume Mounts" allowing Container Runtime Interface (CRI) to mount images directly as local volumes.  
This deprecates the necessity for process namespace sharing, VFS traversal hacks, and sidecar execution.  
  
2. KServe meanwhile abstracts this complexity through its core storage initializer controller. 
When a deployment`InferenceService`manifest specifies an `oci://` storage URI schema, KServe intercepts the admission request.    

`enableModelcar` within KServe's `inferenceservice-config` transforms the Pod spec at runtime injecting the shared `emptyDir` , provisioning the sidecar container and appending the symbolic link `ln -s /proc/...`   

#### Deployment 

```bash
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: smollm-modelcar
  namespace: kserve-test
  annotations:
    serving.kserve.io/deploymentMode: Standard
spec:
  predictor:
    model:
      modelFormat:
        name: custom
      storageUri: "oci://docker.io/library/modelcar-tiny-gguf:latest"
      containers:
      - name: kserve-container
        image: ghcr.io/ggml-org/llama.cpp:server
        args:
        - "-m"
        - "/mnt/models/models/model.gguf"
        - "--host"
        - "0.0.0.0"
        - "--port"
        - "8080"
        - "--ctx-size"
        - "1024"
        ports:
        - containerPort: 8080
          protocol: TCP
        resources:
          requests:
            cpu: "200m"
            memory: "512Mi"
          limits:
            cpu: "1"
            memory: "1Gi"
```{{exec}}
  
```bash
kubectl apply -f inferenceservice.yaml
```{{exec}}
  
