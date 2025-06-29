#!/bin/bash

REPO="https://github.com/Werest/shvirtd-example-python"
DIR="/opt/app"
REGISTRY_ID=$(cat /opt/app/registry_id)
IMAGE_NAME="webapp"
TAG="latest"
FULL_IMAGE="cr.yandex/${REGISTRY_ID}/${IMAGE_NAME}:${TAG}"

# Удаляем старый каталог и клонируем заново
sudo rm -rf $DIR/shvirtd-example-python
git clone $REPO $DIR/shvirtd-example-python
cd $DIR/shvirtd-example-python

# Собираем Docker образ
docker build -t $IMAGE_NAME .

# Логинимся в Container Registry
yc container registry configure-docker
docker login --username iam --password $(yc iam create-token) cr.yandex

# Помечаем и пушим образ в Registry
docker tag $IMAGE_NAME $FULL_IMAGE
docker push $FULL_IMAGE

# Удаляем локальный образ
docker rmi $IMAGE_NAME $FULL_IMAGE

# Запускаем приложение из образа в Registry
docker pull $FULL_IMAGE
docker tag $FULL_IMAGE $IMAGE_NAME

# Запускаем compose (должен использовать образ из registry)
docker compose -f compose.yaml up -d
