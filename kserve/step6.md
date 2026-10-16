## InferenceService Abstraction and Native Volumes

Define the `InferenceService` using Standard deployment mode and the `oci://` URI[cite: 59, 68]. The controller automatically injects the `emptyDir`, configures process namespace sharing, and attaches the sidecar[cite: 68]. The model format specifies the framework, and the runtime parameter specifies the engine[cite: 59]. I limiti estremi di vLLM vengono iniettati direttamente nei container spec per evitare il crash del nodo.

```bash
cat << 'EOF_YAML' > inferenceservice.yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: qwen-modelcar
  annotations:
    serving.kserve.io/deploymentMode: Standard
spec:
  predictor:
    model:
      modelFormat:
        name: pytorch
      runtime: vllm
      storageUri: "oci://modelcar-qwen:latest"
      containers:
      - env:
        - name: VLLM_TARGET_DEVICE
          value: "cpu"
        args:
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

Apply the deployment.

```bash
kubectl apply -f inferenceservice.yaml
```

### Deprecation Path: Native OCI Image Volumes

Modelcars serve as a temporary bridge technology[cite: 68]. Kubernetes 1.31 introduced native OCI Image Volume Mounts (beta in 1.35), permitting pods to mount images directly as volumes without process namespace sharing or `/proc` hacks[cite: 74, 110]. 

Images structured with models inside the `/models` directory provide forward compatibility[cite: 111]. The `subPath: models` directive enables migration to native image volumes without rebuilding artifacts[cite: 111].
