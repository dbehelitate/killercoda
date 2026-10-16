## Step 2: Passive OCI Artifact Packaging

## Architectural Theory

An OCI registry functions as a centralized model registry by encapsulating the model weights directly within container layers, eliminating the need for external storage references. 

Packaging models as OCI images enables Kubernetes nodes to deduplicate identical layers across specialized models that share foundational weights, leveraging local caching mechanisms for maximum efficiency. 

This creates a data-only image that is never executed for compute; it exists solely to deliver read-only filesystem layers to the host node.

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

docker build -t modelcar-tinygpt2:latest .
```{{exec}}
