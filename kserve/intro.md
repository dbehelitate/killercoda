## Architecture and Objectives
  
### 0) Zero-Copy Pattern
### 1) COPY 750 Gb of Ai = BAD X   
### 2) READ 750 Gb of Ai =  GOOD V   
  
Copying 750 GB of Ai models to each pod , it's a bottleneck.  
Each pod reading a Model without copying files it's better.

That's why we use KServe and don't use emptydir , or pull a model in every pod.
  
This is the Example but the same logic and pattern can be used WITHOUT KSERVE and we are going to show how KSERVE USE SYMLINK to build the modelcar.
  
![KServe Modelcar Architecture](./assets/OCI.ModelContainer.-emptydir-.png)
  
**KServe OCI Container**
https://kserve.github.io/website/docs/model-serving/storage/providers/oci?utm_source=kapa#example
  
**TinyGPT2**
https://huggingface.co/collections/Qwen/qwen25
  
  

