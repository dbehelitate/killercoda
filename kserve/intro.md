## Architecture and Objectives
  
### 0) Zero-Copy Pattern
### 1) COPY 750 Gb of Ai = BAD X   
### 2) READ 750 Gb of Ai =  GOOD V   
  
Copying 750 GB of Ai models to each pod , it's a bottleneck.  
Each pod reading a Model without copying files it's better.

That's why we use KServe and don't use emptydir , or pull a model in every pod.
  
This is the Example but the same logic and pattern can be used WITHOUT KSERVE and we are going to show how KSERVE USE SYMLINK to build the modelcar.
  
https://kserve.github.io/website/docs/model-serving/storage/providers/oci?utm_source=kapa#example

![KServe Modelcar Architecture](./assets/OCI.ModelContainer.-emptydir-.png)


  
**KServe Documentation**:
Declarative deployment of KServe's `InferenceService`.
https://kserve.github.io/website/docs/model-serving/generative-inference/llmisvc/llmisvc-overview
  
**Qwen 2.5 Ai**
https://huggingface.co/collections/Qwen/qwen25

**IMPORTANT CONCEPTS**:
Linux process namespace sharing (`shareProcessNamespace: true`):
https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/
symlinks: https://man7.org/linux/man-pages/man2/symlink.2.html
   
