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

## Manual Deploying with $$$$ of TinyGPT

Write and apply the manual Pod manifest to validate the underlying Linux kernel primitives before introducing control plane automation.



```bash
# 1. Crea il namespace di workload (se non esiste già)
kubectl create namespace kserve-test --dry-run=client -o yaml | kubectl apply -f -
```{{exec}}

```bash
# 3. Crea il Pod usando il runtime HuggingFace CPU-only
cat << 'EOF_YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: tinygpt2
  namespace: kserve-test
spec:
  shareProcessNamespace: true
  containers:
  - name: kserve-container
    image: kserve/huggingfaceserver:v0.13.0
    args:
    - "--model_name"
    - "tinygpt2"
    - "--model_dir"
    - "/mnt/models"
    ports:
    - containerPort: 8080
    resources:
      requests:
        cpu: "500m"
        memory: "512Mi"
      limits:
        cpu: "2"
        memory: "2Gi"
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
EOF_YAML
```{{exec}}

```bash
# 4. Attendi che il Pod sia completamente operativo
kubectl wait --for=condition=Ready --timeout=150s -n kserve-test pod/tinygpt2
```{{exec}}

IN COSTRUZIONE
KSERVE NATIVE WAY


```bash
#  Rimuovi il pod precedente (se bloccato o in errore)
kubectl delete pod tinygpt2 -n kserve-test --ignore-not-found
```{{exec}}


```bash
# 1. Abilita Modelcar nel control plane di KServe
kubectl patch configmap inferenceservice-config -n kserve \
  --type merge \
  -p '{"data": {"storageInitializer": "{\"enableModelcar\": true}"}}'
```{{exec}}

```bash
# 2. Crea il namespace di workload
kubectl create namespace kserve-test --dry-run=client -o yaml | kubectl apply -f -
```{{exec}}

```bash
# 3. COMPONENTE MANCANTE: Build e Import in containerd con tag :1.0
docker build -t modelcar-tinygpt2:1.0 . && \
docker save modelcar-tinygpt2:1.0 | ctr -n k8s.io images import -
```{{exec}}

```bash
# 4. Applica il KServe InferenceService nativo
kubectl apply -n kserve-test -f - <<'EOF'
apiVersion: "serving.kserve.io/v1beta1"
kind: "InferenceService"
metadata:
  name: "tinygpt2"
spec:
  predictor:
    model:
      modelFormat:
        name: "huggingface"
      storageUri: "oci://modelcar-tinygpt2:1.0"
      resources:
        requests:
          cpu: "500m"
          memory: "1Gi"
        limits:
          cpu: "2"
          memory: "2Gi"
EOF
```{{exec}}

```bash
# 5. Monitora l'InferenceService fino a quando non è pronto
kubectl wait --for=condition=Ready --timeout=150s -n kserve-test inferenceservice/tinygpt2
```{{exec}}
