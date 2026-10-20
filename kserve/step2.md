# Step 2: pull SmolGPT 

An OCI registry encapsulates the model weights within containers.
 
OCI:  
https://www.docker.com/blog/oci-artifacts-for-ai-model-packaging/
  
KServe Example:  
https://kserve.github.io/website/docs/model-serving/storage/providers/oci?utm_source=kapa#example


  
## OCI and Kubernetes
Packaging Ai models as OCI images enables Kubernetes nodes to decouple layers.


## Deployment Execution

Create the `Dockerfile` and executethe image build. 
    
The `git clone` command fetches the model weights.

```bash
cat << 'EOF_DOCKER' > Dockerfile
FROM alpine
RUN apk add --no-cache curl ca-certificates
RUN mkdir -p /models
# Il flag -f (fail) impedisce a curl di salvare pagine di errore 404
RUN curl -fsSL -o /models/model.gguf https://huggingface.co/bartowski/SmolLM2-135M-Instruct-GGUF/resolve/main/SmolLM2-135M-Instruct-Q4_K_M.gguf
EOF_DOCKER

# Ricostruiamo e importiamo in containerd
docker build -t docker.io/library/modelcar-tiny-gguf:latest . && \
docker save docker.io/library/modelcar-tiny-gguf:latest | sudo ctr -n k8s.io images import - && \
docker rmi docker.io/library/modelcar-tiny-gguf:latest
```{{exec}}


Kubernetes uses a different RunTime than Docker.
We need to build and inject it inside containerd namespace.
(`k8s.io` is  `containerd` ns). 
