## GPT in OCI Sidecar 

Copying 750GB to every pod is a bottleneck.  
    ❌ **Copy** 750GB = emptyDir/initContainer  
    ✅ **Read** 750GB = symlink/KServe  
  
![KServe Modelcar Architecture](./assets/OCI.ModelContainer.-emptydir-.png)  
  
1) We'll learn to deploy ONE ChatBOT with Symlink(MANUAL POD)   
2) We'll learn to deploy HOUNDREDS of ChatBOT with LLMInferenceService (KServe)  

KServe OCI Example:  
https://kserve.github.io/website/docs/model-serving/storage/providers/oci
  
⚠️ 
Kubernetes native way of reading OCI pulled Models uses emptyDir but Image VOlumes have been introduced recently as well.
Meanwhile KServe uses symlinks to achieve this and PV is another Method with it's ow niche.  
Manually orchestrating container sidecars and process namespaces across hundreds of production workloads is unmaintainable that's why we use KServe.  
    

  








    




