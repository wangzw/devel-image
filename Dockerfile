FROM ghcr.io/wangzw/devel-toolchain:1.0.0-gcc-13-llvm-17 AS build

COPY . /workspace/

RUN mkdir -p /workspace/build                                                         \
    && cmake -S /workspace/ -B /workspace/build                                       \
         -DCMAKE_TOOLCHAIN_FILE=/workspace/cmake/build-toolchain.cmake                \
         -DCMAKE_INSTALL_PREFIX=/opt/develop/root/usr                                 \
    && cmake --build /workspace/build --parallel $(nproc --all)                       \
    && cmake --install /workspace/build                                               \
    && cmake --build /workspace/build -t strip-all

FROM ghcr.io/wangzw/devel-toolchain:1.0.0-gcc-13-llvm-17
LABEL authors="Zhanwei Wang"

COPY --from=build /opt/develop /opt/develop

RUN ln -s /opt/develop/root/usr/devel-toolchain.cmake /opt/devel-toolchain.cmake
