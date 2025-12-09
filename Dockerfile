FROM ghcr.io/wangzw/devel-toolchain:latest AS build

RUN --mount=type=bind,rw,source=.,target=/workspace <<EOF
  set -eux
  rm -rf /workspace/build
  mkdir -p /workspace/build
  mkdir -p /opt/develop/root/usr
  cmake -S /workspace/ -B /workspace/build                                        \
    -DCMAKE_TOOLCHAIN_FILE=/workspace/cmake/build-gcc-toolset-15-toolchain.cmake  \
    -DCMAKE_INSTALL_PREFIX=/opt/develop/root/usr
  cmake --build /workspace/build --parallel $(nproc --all)
  cmake --install /workspace/build
  cmake --build /workspace/build -t strip-all
EOF

FROM ghcr.io/wangzw/devel-toolchain:gcc-14-llvm-19
LABEL authors="Zhanwei Wang"

COPY --from=build /opt/develop /opt/develop

RUN ln -s /opt/develop/root/usr/devel-toolchain.cmake /opt/devel-toolchain.cmake
