### Step1: Pull SmolGPT in an OCI Container  

Goal: Zero-Copy AI  
❌ COPY 750GB = 🐢  
✅ READ 750GB = 🚀  
  
⚠️ Copying 750GB to every pod is a bottleneck. Reading directly is the fix.
Instead of using emptyDir, KServe uses symlinks to achieve this. Let's build the modelcar pattern from scratch to see exactly how it works under the hood.
     
![KServe Modelcar Architecture](./assets/OCI.ModelContainer.-emptydir-.png)
  
  
OCI:
https://www.docker.com/blog/oci-artifacts-for-ai-model-packaging/

KServe Example:
https://kserve.github.io/website/docs/model-serving/storage/providers/oci?utm_source=kapa#example

OCI and Kubernetes
Packaging Ai models as OCI images enables Kubernetes nodes to decouple layers.


## Architectural Theory

Manually orchestrating container sidecars and process namespaces across hundreds of production workloads is unmaintainable. KServe abstracts this complexity through its core storage initializer controller. 

When a deployment manifest specifies an `oci://` storage URI schema, KServe intercepts the admission request. By enabling the `enableModelcar` parameter within KServe's global configuration (`inferenceservice-config`), the system's mutating admission webhook dynamically transforms the Pod specification at runtime. It automatically injects the shared `emptyDir` memory spaces, provisions the modelcar sidecar container, and appends the requisite symbolic linking logic (`ln -s /proc/...`) without requiring manual operator intervention.



