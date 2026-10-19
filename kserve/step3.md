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
cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: tiny-gguf
  namespace: kserve-test
spec:
  shareProcessNamespace: true
  containers:
  - name: kserve-container
    image: ghcr.io/ggml-org/llama.cpp:server
    command:
    - "/bin/sh"
    - "-c"
    args:
    - |
      while [ ! -f /mnt/models/model.gguf ]; do
        echo "Waiting for modelcar symlink...";
        sleep 1;
      done;
      # Usiamo il percorso assoluto /llama-server per massima sicurezza (da YAML 2)
      exec /llama-server -m /mnt/models/model.gguf --host 0.0.0.0 --port 8080
    ports:
    - containerPort: 8080
    resources:
      requests:
        cpu: "100m"
        memory: "256Mi"
      limits:
        cpu: "1"
        memory: "1Gi"
    volumeMounts:
    - mountPath: /mnt
      name: kserve-provision-location
  - name: modelcar
    image: docker.io/library/modelcar-tiny-gguf:latest
    imagePullPolicy: Never
    command:
    - "/bin/sh"
    - "-c"
    args:
    - |
      # Il formato multi-riga è più pulito e gestisce i PID nativamente (da YAML 1)
      PID=$$
      ln -sf /proc/$PID/root/models /mnt/models
      sleep infinity
    resources:
      requests:
        cpu: "10m"
        memory: "15Mi"
      limits:
        cpu: "10m"
        memory: "15Mi"
    volumeMounts:
    - mountPath: /mnt
      name: kserve-provision-location
  volumes:
  - name: kserve-provision-location
    emptyDir: {}
EOF
```{{exec}}

kubectl get pods -n kserve-test -w

```bash
# 4. Attendi che il Pod sia completamente operativo (50 secondi)
kubectl wait --for=condition=Ready --timeout=50s -n kserve-test pod/tinygpt2
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
