#!/bin/bash

set -e

ROOT_DIR=$(cd "$(dirname "$0")"; pwd)/..

TAG=$(echo $GIT_COMMIT | cut -c1-7)
docker login -u ${DOCKER_HUB_LOGIN} -p ${DOCKER_HUB_PASSWORD}

# Run tests and all the other checks on repo
docker build -f ${ROOT_DIR}/build/CI/Dockerfile ${ROOT_DIR}

# Metadata Plugin Broker
docker build -t eclipse/che-metadata-plugin-broker:latest -f ${ROOT_DIR}/build/metadata/Dockerfile ${ROOT_DIR}
docker tag eclipse/che-metadata-plugin-broker:latest eclipse/che-metadata-plugin-broker:${TAG}
docker push eclipse/che-metadata-plugin-broker:latest
docker push eclipse/che-metadata-plugin-broker:${TAG}

# Artifacts Plugin Broker
docker build -t eclipse/che-artifacts-plugin-broker:latest -f ${ROOT_DIR}/build/artifacts/Dockerfile ${ROOT_DIR}
docker tag eclipse/che-artifacts-plugin-broker:latest eclipse/che-artifacts-plugin-broker:${TAG}
docker push eclipse/che-artifacts-plugin-broker:latest
docker push eclipse/che-artifacts-plugin-broker:${TAG}

# Development image
docker build -t eclipse/che-plugin-broker-dev:latest -f ${ROOT_DIR}/build/dev/Dockerfile ${ROOT_DIR}
docker tag eclipse/che-plugin-broker-dev:latest eclipse/che-plugin-broker-dev:${TAG}
docker push eclipse/che-plugin-broker-dev:latest
docker push eclipse/che-plugin-broker-dev:${TAG}
