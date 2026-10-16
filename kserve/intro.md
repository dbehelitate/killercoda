This scenario demonstrates zero-copy model sharing using an OCI Modelcar container sidecar.

![KServe Modelcar Architecture](./kserve/assets/OCI.ModelContainer.-emptydir-.png)

You will manually rebuild the sidecar architecture using process namespace sharing and `/proc` symlinking to expose model weights without duplication, then abstract the workload using KServe's `InferenceService`.
