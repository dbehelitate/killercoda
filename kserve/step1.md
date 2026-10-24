### Step1: Pull SmolGPT in an OCI Container  

⚠️**Copying 750GB to every pod is a bottleneck. Reading directly is the fix via SYM LINK**
  
❌ **COPY** 750GB = SLOW &nbsp;  (emptyDir / initContainer) ❌   
✅ **READ** 750GB = SCHNELL &nbsp;   (SYM LINK / KServe) ✅  
  
![KServe Modelcar Architecture](./assets/OCI.ModelContainer.-emptydir-.png)
  
1) We'll learn to deploy ONE chatBOT with SYMLINK(MANUAL POD) 
2) We'll learn to deploy HOUNDREDS of ChatBOT with LLMInferenceService (KServe)

KServe OCI Example:  
https://kserve.github.io/website/docs/model-serving/storage/providers/oci?utm_source=kapa#example  
  
[NOT FOR CASUALS]    
⚠️ Manually orchestrating container sidecars and process namespaces across hundreds of production workloads is unmaintainable that's why we use KServe.
Packaging Ai models as OCI images enables Kubernetes nodes to decouple layers. 
Kubernetes native way of reading OCI pulled from HuggingFace uses emptyDir while KServe uses symlinks to achieve this.







    
KServe abstracts this complexity through its core storage initializer controller. 
When a deployment manifest specifies an `oci://` storage URI schema, KServe intercepts the admission request. By enabling the `enableModelcar` parameter within KServe's global configuration (`inferenceservice-config`), the system's mutating admission webhook dynamically transforms the Pod specification at runtime. It automatically injects the shared `emptyDir` memory spaces, provisions the modelcar sidecar container, and appends the requisite symbolic linking logic (`ln -s /proc/...`) without requiring manual operator intervention.



