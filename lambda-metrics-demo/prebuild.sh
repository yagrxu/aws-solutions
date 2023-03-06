#!/bin/bash

cd lambda
# pip3 install --target ./package opentelemetry-api==1.16.0 -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade
# pip3 install --target ./package opentelemetry-sdk==1.16.0 -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade
# pip3 install --target ./package opentelemetry-exporter-otlp==1.16.0 -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade
pip3 install --target ./package opentelemetry-api==1.16.0 --upgrade
pip3 install --target ./package opentelemetry-sdk==1.16.0 --upgrade
pip3 install --target ./package opentelemetry-exporter-otlp==1.16.0 --upgrade

# pip3 install --target ./package cygrpc --upgrade
cd package
zip -r ../metrics-demo.zip .
cd ..
zip -g metrics-demo.zip index.py
cd ..
mv ./lambda/metrics-demo.zip ./tf/
