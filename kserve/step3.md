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
    args:
      - "-m"
      - "/mnt/models/model.gguf"
      - "--host"
      - "0.0.0.0"
      - "--port"
      - "8080"
      - "--ctx-size"
      - "1024"
    ports:
    - containerPort: 8080
    resources:
      requests:
        cpu: "200m"
        memory: "512Mi"
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
      ln -sf /proc/$$$$/root/models /mnt/models && sleep infinity
    resources:
      requests:
        cpu: "10m"
        memory: "15Mi"
      limits:
        cpu: "20m"
        memory: "30Mi"
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


AI HELLO WORLD:
  
```bash
POD_IP=$(kubectl get pod tiny-gguf -n kserve-test -o jsonpath='{.status.podIP}')

curl -s -X POST http://$POD_IP:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "You are a highly creative sci-fi AI. Generate a numbered list of 3 dramatic, cinematic ways to say '\''Hello World'\''. You MUST use cool and relevant emojis (like 🤖, 🌌, 🚀, ⚡) in every single line."},
      {"role": "user", "content": "Give me 3 sci-fi variations of Hello World with emojis!"}
    ],
    "max_tokens": 150,
    "temperature": 0.8
  }' | jq -r '.choices[0].message.content'
```

Step Y: Click and Play! 🎈
Now let's open a magic window to chat with our robot on the internet!

```bash
kubectl port-forward --address 0.0.0.0 pod/tiny-gguf -n kserve-test 8080:8080 > /dev/null 2>&1 &
```

We open a secret tunnel from inside the cloud straight to port 8080.

Click the Traffic or Ports button at the top of your Killercoda screen, type 8080, and click the link to open your robot chat window!
