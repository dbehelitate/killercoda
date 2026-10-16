# KserveCar--symlink-->ModelCar

This scenario demonstrates the implementation of zero-copy Large Language Model (LLM) weight sharing utilizing Open Container Initiative (OCI) modelcar sidecars.
  
Traditional deployments suffer I/O bottlenecks by copying massive model weights to ephemeral volumes. KServe mitigates this using Open Container Initiative (OCI) image standards. 
  
This demonstrates the injection of sidecars and shared memory volumes to abstract underlying kernel primitives.

## Architecture and Objectives
The workload execution is divided into two distinct technical phases:

**Manual Primitive Reconstruction**:
   
 -Linux process namespace sharing (`shareProcessNamespace: true`)
    
 -symlinks , read only without copy.
   
    
![KServe Modelcar Architecture](./assets/OCI.ModelContainer.-emptydir-.png)


The Kubernetes Container Runtime Interface (CRI) allows instantaneous, zero-copy sharing of foundational weights across pods.


**Control Plane Abstraction**:

-Declarative deployment of KServe's `InferenceService`.

Kserve LLMInferenceSerivce: 
https://kserve.github.io/website/docs/model-serving/generative-inference/llmisvc/llmisvc-overview
  

