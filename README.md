# Kubernetes Resource

## Testing

`make test`

## Installing

```
resource_types:
- name: kubernetes
  type: docker-image
  source:
    repository: periscopedata/concourse-kubectl-resource
resources:
- name: kubernetes_with_sidecar
  type: kubernetes
  source:
    namespace: default
    use_sidecar_kubectl_proxy: true

- name: kubernetes_remote
  type: kubernetes
  source:
    namespace: default
    cluster_url: https://hostname:port
    cluster_ca: _base64 encoded CA pem_
    admin_key: _base64 encoded key pem_
    admin_cert: _base64 encoded certificate_
```

## Source Configuration

* `use_sidecar_kubectl_proxy`: *Optional.* If true, connect to a sidecar kubectl proxy on port 8001 running on the garden host.
* `cluster_url`: *Optional.* URL to Kubernetes Master API service. Required if `use_sidecar_kubectl_proxy` is false.
* `namespace`: *Optional.* Kubernetes namespace.
* `cluster_ca`: *Optional.* Base64 encoded PEM. Required if `cluster_url` is https.
* `admin_key`: *Optional.* Base64 encoded PEM. Required if `cluster_url` is https.
* `admin_cert`: *Optional.* Base64 encoded PEM. Required if `cluster_url` is https.



#### `out`: Begins Kubernetes Deploy Process

Applies a kubectl action.

#### Parameters
* `path`: *Required.* Path to directory containing yaml files.

## Example

### Out
```
---
resources:
- name: k8s
  type: kubernetes
  source:
    namespace: default
    use_sidecar_kubectl_proxy: true
```

```
---
- put: k8s
  params:
    path: cluster/deployments
```
