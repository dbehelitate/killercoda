# Step 2: Architecture
  
![KServe Modelcar Architecture](./assets/OCI.ModelContainer.-emptydir-.png)
  
Goal: Zero-Copy AI  
❌ COPY 750GB = 🐢  
✅ READ 750GB = 🚀  

⚠️ Copying 750GB to every pod is a bottleneck. Reading directly is the fix.
Instead of using emptyDir, KServe uses symlinks to achieve this. Let's build the modelcar pattern from scratch to see exactly how it works under the hood.
   
## OCI and Kubernetes
Packaging Ai models as OCI images enables Kubernetes nodes to decouple layers.

## Deployment Execution
Create the `Dockerfile` and executethe image build. 
The `git clone` command fetches the model weights.
Kubernetes uses a different RunTime than Docker.
We need to build and inject it inside containerd namespace so we wil use "sudo ctr" (`k8s.io` is  `containerd` ns).
  
```bash
cat << 'EOF_DOCKER' > Dockerfile
FROM alpine
RUN apk add --no-cache curl ca-certificates
RUN mkdir -p /models
RUN curl -fsSL -o /models/model.gguf https://huggingface.co/bartowski/SmolLM2-135M-Instruct-GGUF/resolve/main/SmolLM2-135M-Instruct-Q4_K_M.gguf
EOF_DOCKER

# Ricostruiamo e importiamo in containerd
docker build -t docker.io/library/modelcar-tiny-gguf:latest . && \
docker save docker.io/library/modelcar-tiny-gguf:latest | sudo ctr -n k8s.io images import - && \
docker rmi docker.io/library/modelcar-tiny-gguf:latest
```{{exec}}



