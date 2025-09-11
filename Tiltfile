# Tiltfile (Starlark)

# 1) Safety: only deploy to these kube-contexts
allow_k8s_contexts(['kind-llmworks', 'minikube'])

# 2) Cluster-scoped dev bits (namespace, etc.)
k8s_yaml('k8s/dev/namespace.yaml')

# 3) Build images locally (tags will be :tilt)
docker_build(
    'ghcr.io/lukewyman/llmworks/svc-1',
    context='services/svc-1',
    dockerfile='services/svc-1/Dockerfile.dev',
)
docker_build(
    'ghcr.io/lukewyman/llmworks/svc-2',
    context='services/svc-2',
    dockerfile='services/svc-2/Dockerfile.dev',
)

# 4) Render Helm -> YAML -> apply (no extensions needed)
svc1_yaml = local(
    "helm template svc-1 ./helm/svc-1 --namespace llmworks "
    + "--set image.repository=ghcr.io/lukewyman/llmworks/svc-1 "
    + "--set image.tag=tilt",
    quiet=True,
)
k8s_yaml(svc1_yaml)
k8s_resource('svc-1', port_forwards=[8080])

svc2_yaml = local(
    "helm template svc-2 ./helm/svc-2 --namespace llmworks "
    + "--set image.repository=ghcr.io/lukewyman/llmworks/svc-2 "
    + "--set image.tag=tilt",
    quiet=True,
)
k8s_yaml(svc2_yaml)
k8s_resource('svc-2', port_forwards=[8081])
