## Validating VFS Cross-Container Traversal

The `shareProcessNamespace: true` directive commands the container runtime to merge all containers into a single PID namespace, allowing cross-container Virtual File System (VFS) access via `/proc`[cite: 105, 108]. The symbolic link directs the `vllm-server` to the `modelcar`'s cached OCI overlay layer, duplicating zero bytes to disk[cite: 104, 108].

Verify the runtime perceives the model weights as locally present in `/mnt/models`[cite: 108].

```bash
kubectl exec -it vllm-manual-modelcar -c vllm-server -- ls -la /mnt/models
```

### Architectural Hazards

This architecture introduces strict operational hazards:

1. **Startup Race Conditions**: The serving runtime and modelcar container initialize in parallel[cite: 109]. If the runtime starts before the symlink is placed, the deployment crashes[cite: 109]. Native Kubernetes 1.28+ sidecars (`initContainers` with `restartPolicy: Always`) are required to enforce startup ordering[cite: 109].
2. **Security Degradation**: `shareProcessNamespace` destroys Pod isolation boundaries[cite: 109]. Service meshes like Istio do not encrypt local configurations; sidecar injection exposes mTLS tokens and environment variables across the namespace[cite: 109].
