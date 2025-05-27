#!/bin/bash

REPO="https://github.com/Werest/shvirtd-example-python"
DIR="/opt/app"

sudo rm -rf $DIR

sudo git clone $REPO $DIR
cd $DIR

sudo docker compose -f compose.yaml up -d