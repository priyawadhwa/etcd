#!/usr/bin/env bash

set -ex

eval $(minikube docker-env)
echo "Building new etcd image ..."
docker build -t etcd -f dockerfiles/Dockerfile bin/
echo "Replacing current etcd image with new image ..."
minikube ssh -- sudo sed -i 's/image:.*/image:\ etcd:latest/' /etc/kubernetes/manifests/etcd.yaml
echo "Removing old docker container ..."
minikube update-context || true
kubectl delete po etcd-minikube -n kube-system
sleep 3
DOCKER_CONTAINER_NAME=$(minikube ssh -- docker ps --format {{.Names}} | grep k8s_etcd)
minikube ssh -- docker stop $DOCKER_CONTAINER_NAME
minikube ssh -- docker rm $DOCKER_CONTAINER_NAME
