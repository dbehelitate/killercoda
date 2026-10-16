# Scenario: Zero-Copy Model Provisioning via OCI Modelcars

## Abstract
This scenario demonstrates the implementation of zero-copy Large Language Model (LLM) weight sharing utilizing Open Container Initiative (OCI) modelcar sidecars.

![KServe Modelcar Architecture](./assets/OCI.ModelContainer.-emptydir-.png)

Traditional deployments suffer I/O bottlenecks by copying massive model weights to ephemeral volumes. KServe mitigates this using Open Container Initiative (OCI) image standards. 

The Kubernetes Container Runtime Interface (CRI) allows instantaneous, zero-copy sharing of foundational weights across pods.

## Architecture and Objectives
The workload execution is divided into two distinct technical phases:

1. **Manual Primitive Reconstruction**:
   -Direct manipulation of Linux process namespace sharing (`shareProcessNamespace: true`)
   -`/proc` symlinking. This exposes read-only OCI image layers across pod container boundaries without physical data duplication.
   
3. **Control Plane Abstraction**: Declarative deployment of the architecture leveraging KServe's `InferenceService`. This demonstrates the automated, controller-driven injection of sidecars and shared memory volumes to abstract underlying kernel primitives.
