# ModelCar
## Architecture and Objectives
### 1) USING ONLY INITCONTAINERS AND EMPTYDIR IS BAD
### 2) READ Ai vs COPY Ai BOTTLENECKS.
USING INITCONTAINER and EMPTYDIR as a way to download DeepSeak (750gb) AI MODELS to 10 pods 
you wil copy 750 gb to 10 times.
We want to achive 1 MODEL (750 GB) READ BY 10 PODS WITHOUT ADDITIONAL SPACE REQUIRED


![KServe Modelcar Architecture](./assets/OCI.ModelContainer.-emptydir-.png)

The Kubernetes Container Runtime Interface (CRI) allows instantaneous, zero-copy sharing of foundational weights across pods.
  
This scenario demonstrates the implementation of zero-copy Large Language Model (LLM) weight sharing utilizing Open Container Initiative (OCI) modelcar sidecars.
  
This demonstrates the injection of sidecars and shared memory volumes to abstract underlying kernel primitives.

**IMPORTANT CONCEPTS**:
   
 -Linux process namespace sharing (`shareProcessNamespace: true`):
 https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/
    
 -symlinks , read only without copy:
 https://man7.org/linux/man-pages/man2/symlink.2.html
   
  
**Kserve Documentatuion**:

-Declarative deployment of KServe's `InferenceService`.

Kserve LLMInferenceSerivce: 
https://kserve.github.io/website/docs/model-serving/generative-inference/llmisvc/llmisvc-overview
  

