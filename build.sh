#!/bin/bash

VERSION=${VERSION:-$(git rev-parse HEAD)}

docker build -t openresty:${VERSION} .
ID=$(docker run -d openresty:${VERSION} true)
docker export ${ID} | gzip -9 > openresty:${VERSION}.tar.gz
