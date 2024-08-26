# Hello containers

```bash
podman build -t hello .
podman run -it --rm --name=hello -p8080:8080 hello
```

Tag and push.

```
podman tag localhost/hello quay.io/bkozdemb/hello
podman push quay.io/bkozdemb/hello
```

###### Using remote clients.
- The python **minor** versions on the client and server **must** match.
- Ray `2.34.0` requires python `3.9.x`
- `python3.9 -m venv venv`
- `pip install `ray[client]`
- I ran this one liner from my [hello test container](quay.io/bkozdemb/hello) from a pod.
```bash
export RAY_ADDRESS="ray://raycluster-kuberay-head-svc:10001"
python -c 'import ray;ray.init(address="ray://raycluster-kuberay-head-svc:10001");print(ray.cluster_resources())'
 ```
 
```json
{'CPU': 2.0, 'memory': 3000000000.0, 'node:10.134.128.71': 1.0, 'node:10.134.128.103': 1.0, 'object_store_memory': 803996467.0, 'node:__internal_head__': 1.0}
```

