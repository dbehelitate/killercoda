# Step 2: OCI Artifacts  

An OCI registry functions as a centralized model registry by encapsulating the model weights directly within containers.

For more read:   
OCI:  
https://kserve.github.io/website/docs/model-serving/storage/providers/oci?utm_source=kapa#example
  
## OCI and Kubernetes
Packaging Ai models as OCI images enables Kubernetes nodes to deduplicate identical layers across specialized models that share foundational weights, leveraging local caching mechanisms for maximum efficiency. 

This creates a data-only image that is never executed; 
it exists solely to be READ-ONLY from the filesystem.

## Deployment Execution

Create the `Dockerfile` and execute the local container image build. The `git clone` command fetches the model weights directly into the OCI layer.

```bash
cat << 'EOF_DOCKER' > Dockerfile
FROM alpine/git
RUN apk add --no-cache git-lfs \
 && git lfs install \
 && git clone --depth 1 https://huggingface.co/sshleifer/tiny-gpt2 /models
ENTRYPOINT ["sh"]
EOF_DOCKER
```{{exec}}
  
```bash
docker build -t modelcar-tinygpt2:latest .
```{{exec}}
