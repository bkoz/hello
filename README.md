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

Create a python 3.8 env and install ray[client]==2.9.0

```bash
export RAY_ADDRESS="ray://raycluster-kuberay-head-svc:10001"
python -c 'import ray;ray.init(address="ray://raycluster-kuberay-head-svc:10001");print(ray.cluster_resources())'
```

