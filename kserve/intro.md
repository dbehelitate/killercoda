# Zero-Copy Pattern
## Architecture and Objectives
### 1) COPY 750 Gb of Ai = BAD X 
### 2) READ 750 Gb of Ai =  GOOD V 

Copy = 750 GB added to each pod , it's a bottleneck.
Read = 750 Gb is read by each pod without copying files.

https://kserve.github.io/website/docs/model-serving/storage/providers/oci?utm_source=kapa#example

![KServe Modelcar Architecture](./assets/OCI.ModelContainer.-emptydir-.png)

The Kubernetes Container Runtime Interface (CRI) allows instantaneous, zero-copy sharing of foundational weights across pods.
  
This scenario demonstrates the implementation of zero-copy Large Language Model (LLM) weight sharing utilizing Open Container Initiative (OCI) modelcar sidecars.
  
This demonstrates the injection of sidecars and shared memory volumes to abstract underlying kernel primitives.
  
**KServe Documentation**:
Declarative deployment of KServe's `InferenceService`.
https://kserve.github.io/website/docs/model-serving/generative-inference/llmisvc/llmisvc-overview
  
**Qwen 2.5 Ai**
https://huggingface.co/collections/Qwen/qwen25

**IMPORTANT CONCEPTS**:
Linux process namespace sharing (`shareProcessNamespace: true`):
https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/
symlinks: https://man7.org/linux/man-pages/man2/symlink.2.html
   
