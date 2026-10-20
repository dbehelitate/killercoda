# Step 3: llama.cpp container and  TinyGPT sidecar
  
Kubernetes natively isolates container processes.  
To achieve zero-copy data sharing, the Pod specification must share its process namespace in YAML deployment.

```markdown
(`shareProcessNamespace: true`).
This allows the container to “see” other processes from other containers in the same pod.
```
  
A minimal sidecar container (modelcar) executes a sym link pointing the primary inference runtime (llama.cpp) directly to the cached weights via the host's `/proc` hierarchy. 

```markdown
IF USING HEREDOC
$$$$ =  Double $$ are reduced to a single $, which is Kubernetes' mechanism to escape the $(VAR_NAME) syntax and produce a literal $ 
Because of this reduction, writing four dollar signs ($$$$) in the Kubernetes YAML ensures Kubernetes evaluates it down to two dollar signs ($$).
```

Killercoda is only 4gb so we will be aware and avoid Out-Of-Memory (OOM) KERNEL PANICS.

## Manual Deploying with $$$$ of TinyGPT

Write and apply the manual Pod manifest to validate the underlying Linux kernel primitives before introducing control plane automation.

```bash
kubectl create namespace kserve-test --dry-run=client -o yaml | kubectl apply -f -
```{{exec}}

```bash
nano manual-pod.yaml
```{{exec}}

```YAML
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
      - /bin/sh
      - -c
    args:
      - |
        while [ ! -f /mnt/models/model.gguf ]; do
          echo "Waiting for modelcar symlink...";
          sleep 1;
        done;
        exec llama-server -m /mnt/models/model.gguf --host 0.0.0.0 --port 8080
    ports:
    - containerPort: 8080
    resources:
      requests:
        cpu: "100m"
        memory: "256Mi"
      limits:
        cpu: "1"
        memory: "512Mi"
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
    # Utilizzo di $$$$ per passare $$ alla shell, che lo interpreterà come il proprio PID
    - ln -sf /proc/$$$$/root/models /mnt/models && sleep infinity
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
```

```bash
kubectl apply -f manual-pod.yaml
```{{exec}}


Wait for "Running" containers

```bash
#verifica pod
kubectl get pods -n kserve-test -w
```{{exec}}

```bash
#verifica symlink
kubectl exec tiny-gguf -c modelcar -n kserve-test -- ls -la /mnt/
```


AI HELLO WORLD
```bash
POD_IP=$(kubectl get pod tiny-gguf -n kserve-test -o jsonpath='{.status.podIP}')

curl -X POST http://$POD_IP:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "Sei un assistente AI molto conciso."},
      {"role": "user", "content": "Ciao! Scrivi solo Hello World per confermare che funzioni."}
    ],
    "max_tokens": 50,
    "temperature": 0.1
  }'
```


