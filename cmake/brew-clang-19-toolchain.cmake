include(${CMAKE_CURRENT_LIST_DIR}/homebrew-macos.cmake)

list(APPEND CMAKE_PREFIX_PATH ${HOMEBREW_PREFIX}/opt/llvm@19)
set(CMAKE_AR ${HOMEBREW_PREFIX}/opt/llvm@19/bin/llvm-ar)
set(CMAKE_CXX_COMPILER ${HOMEBREW_PREFIX}/opt/llvm@19/bin/clang++)
set(CMAKE_C_COMPILER ${HOMEBREW_PREFIX}/opt/llvm@19/bin/clang)
set(CMAKE_RANLIB ${HOMEBREW_PREFIX}/opt/llvm@19/bin/llvm-ranlib)
set(LLVM_COV_PATH ${HOMEBREW_PREFIX}/opt/llvm@19/bin/llvm-cov)
