# Step 3:  Namespace and Sidecars for TinyGPT
  
Kubernetes natively isolates container processes.  
To achieve zero-copy data sharing, the Pod specification must share its process namespace in YAML deployment.

```markdown
(`shareProcessNamespace: true`).
The Kubernetes’ pod specification supports a relatively unknown property called
shareProcessNamespace. By default, containers that Kubernetes starts for a pod
cannot see each other.
This allows the container to “see” other processes from othercontainers.
```
  
A minimal sidecar container (modelcar) executes a sym link pointing the primary inference runtime (vLLM) directly to the cached weights via the host's `/proc` hierarchy. 

```markdown
$$$$ =  Double $$ are reduced to a single $, which is Kubernetes' mechanism to escape the $(VAR_NAME) syntax and produce a literal $ 
Because of this reduction, writing four dollar signs ($$$$) in the Kubernetes YAML ensures Kubernetes evaluates it down to two dollar signs ($$).
```

Killercoda is only 4gb so  vLLM engine parameters are explicitly constrained to prevent KV cache overallocation and avoid Out-Of-Memory (OOM) KERNEL PANICS on resource-limited nodes.

## Deploying TinyGPT

Write and apply the manual Pod manifest to validate the underlying Linux kernel primitives before introducing control plane automation.

```bash
apiVersion: v1
kind: Pod
metadata:
  name: tinygpt2
  namespace: kserve
spec:
  shareProcessNamespace: true
  containers:
  - name: kserve-container
    image: vllm/vllm-openai-cpu:latest
    env:
    - name: VLLM_TARGET_DEVICE
      value: "cpu"
    args:
    - "--model"
    - "/mnt/models"
    - "--served-model-name"
    - "tinygpt2"
    - "--max-model-len"
    - "128"
    - "--enforce-eager"
    # --- KILLERCODA ONLY SPECS ---
    - "--swap-space"
    - "0"
    - "--max-num-seqs"
    - "2"
    - "--dtype"
    - "float16"
    - "--disable-log-stats"
    # -------------------------------------
    ports:
    - containerPort: 8000
    resources:
      requests:
        cpu: "500m"
        memory: "512Mi"
      limits:
        cpu: "2"
        # Memory limit safely reduced from 3Gi to 1.5Gi
        memory: "1.5Gi" 
    volumeMounts:
    - mountPath: /mnt
      name: kserve-provision-location
      
  - name: modelcar
    image: modelcar-tinygpt2:latest
    imagePullPolicy: Never
    command:
    - "sh"
    - "-c"
    args:
    - "ln -sf /proc/$$$$/root/models /mnt/models && sleep infinity"
    volumeMounts:
    - mountPath: /mnt
      name: kserve-provision-location
      
  volumes:
  - name: kserve-provision-location
    emptyDir: {}
kubectl apply -f manual-pod.yaml
kubectl wait --for=condition=Ready --timeout=50s pod/vllm-manual-modelcar
```{{exec}}


or oci kserve standard

apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: tinygpt2
  namespace: kserve
spec:
  predictor:
    model:
      modelFormat:
        name: huggingface
      
     
      # Force KServe to use TGI's CPU-compiled image instead of the default ClusterServingRuntime
      image: ghcr.io/huggingface/text-generation-inference:latest-cpu
      
      # OCI MODELCAR: 
      # KServe natively handles the sidecar and symlinks for this in the background
      storageUri: oci://modelcar-tinygpt2:latest
      
      env:
        # TGI defaults to port 80, but KServe routes traffic to 8080
        - name: PORT
          value: "8080"
          
      args:
        # 3. TGI-SPECIFIC ARGS: 
        # TGI expects --model-id pointing to KServe's default mount path
        - "--model-id=/mnt/models"
        
      resources:
        requests:
          cpu: "500m"
          memory: "1Gi"
        limits:
          cpu: "2"
          memory: "2Gi"
