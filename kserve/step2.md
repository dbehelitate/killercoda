# Step 2: pull TinyGPT 

An OCI registry encapsulates the model weights within containers.
 
OCI:  
https://kserve.github.io/website/docs/model-serving/storage/providers/oci?utm_source=kapa#example
  
## OCI and Kubernetes
Packaging Ai models as OCI images enables Kubernetes nodes to decouple layers.
It exists solely to be READ-ONLY from the filesystem.

## Deployment Execution

Create the `Dockerfile` and execute the local container image build. The `git clone` command fetches the model weights directly into the OCI layer.

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
docker build -t modelcar-tinygpt2:latest . && \
docker save modelcar-tinygpt2:latest | ctr -n k8s.io images import -
```{{exec}}

In questo modo, non appena Docker finisce di creare l'immagine, questa viene immediatamente "iniettata" nello storage nativo di Kubernetes (`k8s.io` namespace di `containerd`). Quando applicherai il manifest del Pod, non avrai più l'errore `ErrImageNeverPull`.
