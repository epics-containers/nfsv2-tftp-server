NFSv2 and TFTP service
======================

Container image and kubernets config for an NFSv2 and TFTP server.

Contents:

- container_build: Contains Dockerfile and patches to build the 
  image

- example: an example YAML configuration used in tutorial

- yaml: Deployment YAML used in production


To deploy to kubernetes
-----------------------

Current deployment is to the DLS primary network kubernetes cluster.

```
module load hylas
```

The namespace in use is `epics-rtems-test`.

```
kubectl config set-context --current --namespace=epics-rtems-test
```

To apply the config:

```
kubectl apply -f yaml/nfstftpserver.yaml
```

To make changes to the image
----------------------------

The image is built in Gitlab CI when changes are pushed.

When a tag is pushed, the image is built in CI, tagged with the git tag and 
"latest", and pushed to the DLS private container registry.

To deploy an updated image, delete the running pod and it will be
re-created from the "latest" tagged image in the registry.

```
kubectl get pod -o name -l app=nfstftpserver
kubectl delete pod-name
```

Use `kubectl get all` to see all resources in the namespace.
