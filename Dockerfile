ARG LIBRARIES_TAG=latest

FROM ghcr.io/wangzw/devel-libraries:${LIBRARIES_TAG} AS libraries

FROM ghcr.io/wangzw/devel-toolchain:latest
LABEL authors="Zhanwei Wang"

COPY --from=libraries /opt/develop /opt/develop

RUN ln -s /opt/develop/root/usr/devel-toolchain.cmake /opt/devel-toolchain.cmake
