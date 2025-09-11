load('ext://helm', 'helm_release')

allow_k8s_contexts('kind-llmworks', 'minikube')

# Namespace
k8s_yaml('k8s/dev/namespace.yaml')

# svc-1
docker_build(
    ref='ghcr.io/lukewyman/llmworks/svc-1',
    context='services/svc-1',
    dockerfile='services/svc-1/Dockerfile.dev',
)
helm_release(
    name='svc-1',
    chart='./helm/svc-1',
    namespace='llmworks',
    values={'image': {'repository': 'ghcr.io/lukewyman/llmworks/svc-1', 'tag': 'tilt'}}
)
k8s_resource(
    'svc-1', port_forwards=[port_forward(8080, 80)]
)

# svc-2
docker_build(
    ref='ghcr.io/lukewyman/llmworks/svc-2',
    context='services/svc-2',
    dockerfile='services/svc-2/Dockerfile.dev',
)
helm_release(
    name='svc-2',
    chart='./helm/svc-2',
    namespace='llmworks',
    values={'image': {'repository': 'ghcr.io/lukewyman/llmworks/svc-2', 'tag': 'tilt'}}
)
k8s_resource(
    'svc-2', port_forwards=[port_forward(8081, 80)]
)



