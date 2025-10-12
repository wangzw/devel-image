include(${CMAKE_CURRENT_LIST_DIR}/homebrew-macos.cmake)

set(LLVM_VERSION 21)

list(APPEND CMAKE_PREFIX_PATH ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION})

set(CMAKE_C_COMPILER ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/clang)
set(CMAKE_C_COMPILER_AR ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/llvm-ar)
set(CMAKE_C_COMPILER_RANLIB ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/llvm-ranlib)

set(CMAKE_CXX_COMPILER ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/clang++)
set(CMAKE_CXX_COMPILER_AR ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/llvm-ar)
set(CMAKE_CXX_COMPILER_RANLIB ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/llvm-ranlib)

set(CMAKE_AR ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/llvm-ar)
set(CMAKE_RANLIB ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/llvm-ranlib)

set(CMAKE_NM ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/llvm-nm)
set(CMAKE_OBJCOPY ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/llvm-objcopy)
set(CMAKE_OBJDUMP ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/llvm-objdump)
set(CMAKE_ADDR2LINE ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/llvm-addr2line)
set(CMAKE_READELF ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/llvm-readelf)
set(CMAKE_STRIP ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/llvm-strip)

set(GCOV_PATH /usr/bin/gcov)
set(LLVM_COV_PATH ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/llvm-cov)
set(CPPFILT_PATH ${HOMEBREW_PREFIX}/opt/llvm@${LLVM_VERSION}/bin/llvm-cxxfilt)
