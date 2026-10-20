## Architecture and Objectives
  
Goal: Zero-Copy AI  
❌ COPY 750GB = 🐢  
✅ READ 750GB = 🚀  

⚠️ Copying 750GB to every pod is a bottleneck. Reading directly is the fix.
Instead of using emptyDir, KServe uses symlinks to achieve this. Let's build the modelcar pattern from scratch to see exactly how it works under the hood.
  
![KServe Modelcar Architecture](./assets/OCI.ModelContainer.-emptydir-.png)
  
**KServe OCI Container**
https://kserve.github.io/website/docs/model-serving/storage/providers/oci?utm_source=kapa#example
  
**TinyGPT2**
https://huggingface.co/collections/Qwen/qwen25
  
  

