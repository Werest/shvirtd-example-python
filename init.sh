#!/bin/bash
set -euo pipefail


REPO="https://github.com/Werest/shvirtd-example-python"
DIR="/opt/app"
REGISTRY_ID=${REGISTRY_ID}
IMAGE_NAME="webapp"
TAG="latest"
FULL_IMAGE="cr.yandex/${REGISTRY_ID}/${IMAGE_NAME}:${TAG}"

# Удаляем старый каталог и клонируем заново
# sudo rm -rf $DIR/shvirtd-example-python
# git clone $REPO $DIR/shvirtd-example-python
cd $DIR/shvirtd-example-python

# Собираем Docker образ
docker build -t $IMAGE_NAME .

# Авторизация в Container Registry через IAM-токен
IAM_TOKEN=$(curl -s -H "Metadata-Flavor: Google" "http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token" | jq -r '.access_token')

echo "$IAM_TOKEN" | docker login  --username iam  --password-stdin cr.yandex

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
