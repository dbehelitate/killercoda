## Pull SmolGPT in an OCI Container  

⚠️Copying 750GB to every pod is a bottleneck. Reading directly is the fix via SYM LINK  
    ❌ **Copy** 750GB of model weights = slow &nbsp;  
      (emptyDir/initContainer)  
    ✅ **Read** 750GB = fast &nbsp;   
      (symlink/KServe)  
  
![KServe Modelcar Architecture](./assets/OCI.ModelContainer.-emptydir-.png)  
  
1) We'll learn to deploy ONE ChatBOT with Symlink(MANUAL POD)   
2) We'll learn to deploy HOUNDREDS of ChatBOT with LLMInferenceService (KServe)  

KServe OCI Example:  
https://kserve.github.io/website/docs/model-serving/storage/providers/oci
  
⚠️ [NOT FOR CASUALS]    
Kubernetes native way of reading OCI pulled from HuggingFace uses emptyDir while KServe uses symlinks to achieve this.   
  
Manually orchestrating container sidecars and process namespaces across hundreds of production workloads is unmaintainable that's why we use KServe.  
    

  








    




