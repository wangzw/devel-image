FROM ghcr.io/wangzw/devel-toolchain:latest AS build

COPY . /workspace/

RUN rm -rf /workspace/build                                                            \
    && mkdir -p /workspace/build                                                       \
    && mkdir -p /opt/develop/gcc-toolset-14/root/usr                                   \
    && cmake -S /workspace/ -B /workspace/build                                        \
         -DCMAKE_TOOLCHAIN_FILE=/workspace/cmake/build-gcc-toolset-14-toolchain.cmake  \
         -DCMAKE_INSTALL_PREFIX=/opt/develop/gcc-toolset-14/root/usr                   \
    && cmake --build /workspace/build --parallel $(nproc --all)                        \
    && cmake --install /workspace/build                                                \
    && cmake --build /workspace/build -t strip-all                                     

RUN rm -rf /workspace/build                                                            \
    mkdir -p /workspace/build                                                          \
    && mkdir -p /opt/develop/llvm-toolset-19/root/usr                                  \
    && cmake -S /workspace/ -B /workspace/build                                        \
         -DCMAKE_TOOLCHAIN_FILE=/workspace/cmake/build-llvm-toolset-19-toolchain.cmake \
         -DCMAKE_INSTALL_PREFIX=/opt/develop/llvm-toolset-19/root/usr                  \
    && cmake --build /workspace/build --parallel $(nproc --all)                        \
    && cmake --install /workspace/build                                                \
    && cmake --build /workspace/build -t strip-all

FROM ghcr.io/wangzw/devel-toolchain:latest
LABEL authors="Zhanwei Wang"

COPY --from=build /opt/develop /opt/develop

RUN cp -a /opt/develop/root/usr/devel-toolchain.cmake /opt/devel-toolchain.cmake
