# Step 2: pull TinyGPT 

An OCI registry encapsulates the model weights within containers.
 
OCI:  
https://kserve.github.io/website/docs/model-serving/storage/providers/oci?utm_source=kapa#example
  
## OCI and Kubernetes
Packaging Ai models as OCI images enables Kubernetes nodes to decouple layers.


## Deployment Execution

Create the `Dockerfile` and executethe image build. 
    
The `git clone` command fetches the model weights.

```bash
cat << 'EOF_DOCKER' > Dockerfile
FROM alpine
RUN apk add --no-cache wget
RUN mkdir -p /models
# Scarichiamo un modello GGUF piccolissimo (~400MB) direttamente in /models
RUN wget -O /models/model.gguf https://huggingface.co/Qwen/Qwen1.5-0.5B-Chat-GGUF/resolve/main/qwen1_5-0_5b-chat-q4_k_m.gguf
ENTRYPOINT ["sh"]
EOF_DOCKER
```{{exec}}

```bash
docker build -t docker.io/library/modelcar-tiny-gguf:latest . && \
docker save docker.io/library/modelcar-tiny-gguf:latest | ctr -n k8s.io images import - && \
docker rmi docker.io/library/modelcar-tiny-gguf:latest
```{{exec}}

Kubernetes uses a different RunTime than Docker.
We need to build and inject it inside containerd namespace.
(`k8s.io` is  `containerd` ns). 
