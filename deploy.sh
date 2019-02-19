#!/bin/bash

NORDVPN_VERSION="2.2.0-2"
REV="1"
IMAGE="bubuntux/nordvpn"
META_TAG="${NORDVPN_VERSION}_${REV}"

echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

process() {
  local img_base=${IMAGE}:${1} 
  local img_ver=${img_base}-${META_TAG}
  docker build -t ${img_ver} --build-arg ARCH=${1} --build-arg VER=${NORDVPN_VERSION} .
  docker push ${img_ver}
  docker tag ${img_ver} ${img_base}-latest
  docker push ${img_base}-latest
}

process "amd64"

sed -i 's/#CROSSRUN/RUN/g' Dockerfile
process "armv7hf"

docker manifest push --purge ${IMAGE}:${META_TAG} || :
docker manifest create ${IMAGE}:${META_TAG} ${IMAGE}:amd64-${META_TAG} ${IMAGE}:armv7hf-${META_TAG}
docker manifest annotate ${IMAGE}:latest ${IMAGE}:armv7hf-${META_TAG} --os linux --arch arm
docker manifest push --purge ${IMAGE}:${META_TAG}

docker manifest push --purge ${IMAGE}:latest || :
docker manifest create ${IMAGE}:latest ${IMAGE}:amd64-latest ${IMAGE}:armv7hf-latest
docker manifest annotate ${IMAGE}:latest ${IMAGE}:armv7hf-latest --os linux --arch arm
docker manifest push --purge ${IMAGE}:latest
