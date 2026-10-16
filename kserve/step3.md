## Manual Architecture: Namespaces and Sidecars

Before relying on the KServe controller, construct the underlying Linux primitives manually. KServe achieves zero-copy execution by utilizing the `shareProcessNamespace` property in the Pod specification[cite: 105].

Write the manual Pod manifest. The sidecar runs an `ln -s` command targeting `/proc/$$$$/root/models` to create a symbolic link into the shared `emptyDir` volume, then executes `sleep infinity` to maintain container uptime[cite: 108]. I parametri vLLM sono configurati esplicitamente per prevenire l'allocazione della KV cache ed evitare crash OOM nel nodo Killercoda.

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
```

Apply the manifest. 

```bash
kubectl apply -f manual-modelcar-pod.yaml
kubectl wait --for=condition=Ready --timeout=300s pod/vllm-manual-modelcar
```
