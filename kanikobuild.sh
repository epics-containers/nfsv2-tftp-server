#!/bin/bash
# Script to be called by .gitlab-ci.yml to perform container build
# using gitlab kubernetes executor

echo 'Building image...'
GROUP=controls
IMAGE_NAME=nfsv2-tftp-server
SUBDIR=container_build
TEMPLATE_CMD="/kaniko/executor --context ${CI_PROJECT_DIR}/${SUBDIR}"
CI_REGISTRY="gcr.io/diamond-privreg"
DESTINATION="${CI_REGISTRY}/${GROUP}/${IMAGE_NAME}"

if [[ -n "${CI_COMMIT_TAG}" ]]; then
    # If there is a tag, push a tagged image with that name.
    CMD="${TEMPLATE_CMD} --dockerfile ${CI_PROJECT_DIR}/${SUBDIR}/Dockerfile --destination ${DESTINATION}:${CI_COMMIT_TAG} --destination ${DESTINATION}:latest"
else
    CMD="${TEMPLATE_CMD} --dockerfile ${CI_PROJECT_DIR}/${SUBDIR}/Dockerfile --no-push"
fi

echo "Command for building image ..."
echo "$CMD"
$CMD || exit 1
