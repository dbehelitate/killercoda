## KServe and Native Volumes

#### The modelcar paradigm: a transitional bridge technology.  

1. Kubernetes 1.35 introduced BETA "OCI Image Volume Mounts" allowing Container Runtime Interface (CRI) to mount images directly as local volumes.  
This deprecates the necessity for process namespace sharing, VFS traversal hacks, and sidecar execution.  
  
2. KServe meanwhile abstracts this complexity through its core storage initializer controller. 
When a deployment`InferenceService`manifest specifies an `oci://` storage URI schema, KServe intercepts the admission request.
  

`enableModelcar` within KServe's `inferenceservice-config` transforms the Pod spec at runtime injecting the shared `emptyDir` , provisioning the sidecar container and appending the symbolic link `ln -s /proc/...`     
  
```markdown
data:
  deploy: |-
    {
      "defaultDeploymentMode": "Serverless",
      "enableModelcar": "true"
    }
```  
  
```bash
kubectl edit configmap inferenceservice-config -n kserve
```

#### Runtime.yaml

```YAML
apiVersion: serving.kserve.io/v1alpha1
kind: ServingRuntime
metadata:
  name: llama-cpp-runtime
  namespace: kserve-test
spec:
  supportedModelFormats:
    - name: custom
      version: "1"
      autoSelect: true
  containers:
    - name: kserve-container
      image: ghcr.io/ggml-org/llama.cpp:server
      args:
        - -m
        - /mnt/models/model.gguf
        - --host
        - 0.0.0.0
        - --port
        - "8080"
        - --ctx-size
        - "1024"
      ports:
        - containerPort: 8080
          protocol: TCP
      resources:
        requests:
          cpu: 200m
          memory: 512Mi
        limits:
          cpu: 1
          memory: 1Gi
```

 #### InferenceService.yaml  
 
 ```YAML
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: tiny-svc
  namespace: kserve-test
spec:
  predictor:
    model:
      modelFormat:
        name: custom
      runtime: llama-cpp-runtime
      storageUri: oci://docker.io/library/modelcar-tiny-gguf:v1
 ```

### Now with some portforwarding you should be able to reach the dashboard.
### If something doesn't work try troubleshooting with AI Help.
### Every logged Mistake is a Victory.
    
```bash
# usefull   
kubectl port-forward -n kserve-test svc/tiny-svc-predictor-default 8080:80

kubectl port-forward --address 0.0.0.0 pod/tiny-gguf -n kserve-test 8080:8080 > /dev/null 2>&1 &
  
kubectl get isvc tiny-svc -n kserve-test

kubectl describe isvc tiny-svc -n kserve-test

kubectl logs tiny-svc-predictor-6658db44f6-8nf4h -c kserve-container -n kserve-test

```
