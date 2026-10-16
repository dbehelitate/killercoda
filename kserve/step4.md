# Step 4: Validating VFS Cross-Container Traversal and Architectural Hazards

## Architectural Theory

The `shareProcessNamespace: true` directive commands the Linux container runtime to merge all containers within the Pod into a unified PID namespace. This permits cross-container Virtual File System (VFS) traversal via the `/proc` filesystem. The symbolic link placed by the sidecar routes the primary inference container directly to the modelcar's cached OCI overlay layer, achieving model access with zero bytes copied to local disk.

While effective for zero-copy data sharing, this manual architecture introduces critical operational vulnerabilities:

1. **Startup Race Conditions**: The serving runtime and modelcar sidecar initialize concurrently. If the serving runtime attempts to access the weights before the modelcar establishes the symbolic link, the deployment enters a crash loop. Resolving this requires native Kubernetes 1.28+ sidecars (`initContainers` with `restartPolicy: Always`) to enforce deterministic startup sequencing.
2. **Security Boundary Degradation**: Unified process namespaces destroy Pod-level security isolation. Service meshes, such as Istio, do not encrypt local configurations; consequently, sidecar injection exposes sensitive mTLS tokens and environment variables across the entire shared namespace, violating zero-trust principles.

## Deployment Execution

Verify that the serving runtime perceives the model weights as locally present within the shared `/mnt/models` directory without any actual data duplication taking place.

```bash
kubectl exec -it vllm-manual-modelcar -c vllm-server -- ls -la /mnt/models
```{{exec}}