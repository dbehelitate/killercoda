## llama.cpp container and model sidecar

Killercoda is only 4gb so we will be aware and    
avoid Out-Of-Memory (OOM) 🕉️ [ KERNEL PANICS ]  
  
```bash
kubectl create namespace kserve-test
```{{exec}}

```bash
nano manual-pod.yaml
```{{exec}}

```YAML
apiVersion: v1
kind: Pod
metadata:
  name: tiny-gguf
  namespace: kserve-test
spec:
  shareProcessNamespace: true
  containers:
  - name: kserve-container
    image: ghcr.io/ggml-org/llama.cpp:server
    args:
      - "-m"
      - "/mnt/models/model.gguf"
      - "--host"
      - "0.0.0.0"
      - "--port"
      - "8080"
      - "--ctx-size"
      - "1024"
    ports:
    - containerPort: 8080
    resources:
      requests:
        cpu: "200m"
        memory: "512Mi"
      limits:
        cpu: "1"
        memory: "1Gi" 
    volumeMounts:
    - mountPath: /mnt
      name: kserve-provision-location
  - name: modelcar
    image: docker.io/library/modelcar-tiny-gguf:latest
    imagePullPolicy: Never
    command:
    - "/bin/sh"
    - "-c"
    args:
    - |
      ln -sf /proc/$$$$/root/models /mnt/models && sleep infinity
    resources:
      requests:
        cpu: "10m"
        memory: "15Mi"
      limits:
        cpu: "20m"
        memory: "30Mi"
    volumeMounts:
    - mountPath: /mnt
      name: kserve-provision-location
  volumes:
  - name: kserve-provision-location
    emptyDir: {}
```

```bash
kubectl apply -f manual-pod.yaml
```{{exec}}

  Wait for "Running" containers

#### Test pod

```bash

kubectl get pods -n kserve-test -w
```{{exec}}

#### Test symlink
  
```bash

kubectl exec tiny-gguf -c modelcar -n kserve-test -- ls -la /mnt/
```

Kubernetes natively isolates container processes.  
To achieve zero-copy data sharing, the Pod specification must share its process namespace in YAML deployment.  

1. (`shareProcessNamespace: true`).
This allows the container to “see” other processes from other containers in the same pod.
      
2. The `$$$$` in my example is needed because of an additional escaping step. The YAML setup I used processes dollar signs before the command reaches the shell, so each `$` needs to be doubled. As a result, `$$$$` becomes `$$`, which the shell then expands to its PID.

YAML itself does not require escaping dollar signs. It's the additional processing or templating layer that makes the difference. If you're writing a plain Kubernetes YAML manifest without such a layer, `$$` should be sufficient.

So, when you see:

`models -> /proc/$/root/models`

something has gone wrong with the escaping or variable expansion. You should see a numeric PID instead of the single `$`.

My suggestion would be to start with a simple shell experiment:

    echo $$
    ln -s /proc/$$/root/models models
    ls -l models

This lets you see the PID expansion directly, without involving YAML or any additional escaping. Note that the process whose PID you reference needs to stay alive for the `/proc/<PID>/root` link to remain valid.

Once you understand that part, you can move the command into your Kubernetes YAML and check what actually reaches the shell. That should help you identify where the extra escaping happens.





