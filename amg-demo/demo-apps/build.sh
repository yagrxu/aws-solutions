#!/bin/bash

echo "build hello service"
sh ./hello/dockerbuild.sh

echo "build world service"
sh ./world/dockerbuild.sh