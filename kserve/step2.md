## OCI and Kubernetes  
Packaging Ai models as OCI images enables Kubernetes nodes to decouple layers.  
An OCI registry encapsulates the model weights within containers.  

## Use this code to Pull SmolLM2 from HUGGIN FACE.
Create the `Dockerfile` and executethe image build. 
The `git clone` command fetches the model weights.
  
```bash
cat << 'EOF_DOCKER' > Dockerfile
FROM alpine
RUN apk add --no-cache curl ca-certificates
RUN mkdir -p /models
RUN curl -fsSL -o /models/model.gguf https://huggingface.co/bartowski/SmolLM2-135M-Instruct-GGUF/resolve/main/SmolLM2-135M-Instruct-Q4_K_M.gguf
EOF_DOCKER
```{{exec}}

## From Docker to Kubernetes
Kubernetes uses a different RunTime than Docker.
We need to build and inject it inside containerd namespace so we wil use "sudo ctr" (`k8s.io` is  `containerd` ns).

```bash
docker build -t docker.io/library/modelcar-tiny-gguf:latest . && \
docker save docker.io/library/modelcar-tiny-gguf:latest | sudo ctr -n k8s.io images import - && \
docker rmi docker.io/library/modelcar-tiny-gguf:latest
```{{exec}}

   






