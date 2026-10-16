## Passive OCI Artifact Packaging

You must build the modelcar image. An OCI registry acts as a model registry by managing the entire model file inside container layers rather than referencing external storage[cite: 93, 94]. Packaging models as OCI images allows nodes to deduplicate layers across specialized models sharing the same foundation and cache data locally[cite: 65, 104].

Create a `Dockerfile` to clone a token-free model (`Qwen2.5-0.5B-Instruct`) into the `/models` directory[cite: 94].

```bash
cat << 'EOF_DOCKER' > Dockerfile
FROM alpine/git
RUN apk add --no-cache git-lfs \
 && git lfs install \
 && git clone --depth 1 [https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct](https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct) /models
ENTRYPOINT ["sh"]
EOF_DOCKER
```

Execute the container image build locally. This creates a passive data image that is never executed for compute; it delivers read-only layers to the host[cite: 94].

```bash
docker build -t modelcar-qwen:latest .
```
