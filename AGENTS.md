# AGENTS.md - Development Guide for AI Coding Agents

## Project Overview

This is a **C++ development environment build system** that creates a Docker image containing 30+ statically-linked C++ libraries and dependencies. The project is a **meta-build system** - it does not contain application source code, but rather orchestrates the building and packaging of third-party libraries into a reproducible development environment.

**Purpose:** Set up a complete C++ development environment with pre-built, statically-linked libraries  
**Author:** Zhanwei Wang  
**License:** Apache License 2.0  
**Registry:** ghcr.io/wangzw/devel

## Key Project Files

This project consists of configuration and build orchestration files. **Third-party library subdirectories (grpc-1.75.1/, prometheus-cpp-1.1.0/, cctz/, etc.) are dependencies and NOT part of the project source.**

### Main Source Files

1. **CMakeLists.txt** (1355 lines) - Core build orchestration
2. **Dockerfile** (22 lines) - Multi-stage Docker image build
3. **cmake/** - Toolchain configuration files
4. **strip-all.sh.in** - Binary stripping script template
5. **env-wrapper.sh.in** - Environment setup script template
6. **.github/workflows/image.yml** - CI/CD pipeline

## Build System

### Build Commands

```bash
# Configure with GCC Toolset 15 (Linux)
cmake -S /root/workspace/devel-image/ -B /root/workspace/devel-image/build \
  -DCMAKE_TOOLCHAIN_FILE=/root/workspace/devel-image/cmake/build-gcc-toolset-15-toolchain.cmake \
  -DCMAKE_INSTALL_PREFIX=/opt/develop/root/usr

# Configure with LLVM Toolset 20 (Linux)
cmake -S /root/workspace/devel-image/ -B /root/workspace/devel-image/build \
  -DCMAKE_TOOLCHAIN_FILE=/root/workspace/devel-image/cmake/build-llvm-toolset-20-toolchain.cmake \
  -DCMAKE_INSTALL_PREFIX=/opt/develop/root/usr

# Configure on macOS (requires Homebrew)
cmake -S /root/workspace/devel-image/ -B /root/workspace/devel-image/build \
  -DCMAKE_TOOLCHAIN_FILE=/root/workspace/devel-image/cmake/brew-clang-toolchain.cmake \
  -DCMAKE_INSTALL_PREFIX=/opt/develop/root/usr

# Build all libraries in parallel
cmake --build /root/workspace/devel-image/build --parallel $(nproc --all)

# Install to prefix location
cmake --install /root/workspace/devel-image/build

# Strip debug symbols (Linux only)
cmake --build /root/workspace/devel-image/build -t strip-all

# Build specific library target
cmake --build /root/workspace/devel-image/build --target <library-name>

# Clean build directory
rm -rf /root/workspace/devel-image/build
```

### Docker Build

```bash
# Build Docker image locally
docker build -t devel-image .

# Multi-platform build (CI/CD approach)
docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/wangzw/devel:latest .
```

### Prerequisites

**Linux:** GCC Toolset 15 or LLVM Toolset 20 (from base image ghcr.io/wangzw/devel-toolchain:latest)  
**macOS:** Homebrew with:
```bash
brew install autoconf autoconf-archive automake flex bison
```

## CMakeLists.txt Structure

The main CMakeLists.txt (1355 lines) uses CMake's `ExternalProject` module to orchestrate building 47+ libraries.

### Key Components

**Lines 1-76:** Project setup and configuration
- Sets C++20 standard, compile flags, and architecture-specific options
- Configures toolchain, install prefix, and static linking
- Creates `strip-all` target for Linux

**Lines 77-1355:** External project definitions (47+ libraries)
- Each library defined with `ExternalProject_Add()`
- Pattern: Download → Configure → Build → Install
- All testing disabled (`-DBUILD_TESTING:BOOL=OFF`)
- Static libraries preferred (`-DBUILD_SHARED_LIBS:BOOL=OFF`)

### Common ExternalProject Pattern

```cmake
ExternalProject_Add(<library-name>
    PREFIX <library-name>
    URL "https://..."  # or GIT_REPOSITORY/GIT_TAG
    URL_HASH "MD5=..."
    DOWNLOAD_DIR "${CMAKE_SOURCE_DIR}/download/<library-name>/"
    SOURCE_DIR "${CMAKE_BINARY_DIR}/<library-name>/src/<version>"
    CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE:PATH=${CMAKE_TOOLCHAIN_FILE}
    CMAKE_CACHE_ARGS
        -DCMAKE_BUILD_TYPE:STRING=Release
        -DCMAKE_CXX_FLAGS:STRING=${DEVELOP_COMPILE_OPTIONS}
        -DCMAKE_CXX_STANDARD:STRING=20
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
        -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
        -DBUILD_TESTING:BOOL=OFF
        -DBUILD_SHARED_LIBS:BOOL=OFF
    DEPENDS <other-library>  # Optional dependency chain
)
```

### Important Variables

- `DEVELOP_COMPILE_OPTIONS` (line 17): Common compile flags for all libraries
- `DEVELOP_STATIC_LINK_FLAGS` (line 19-24): Static linking configuration
- `CMAKE_INSTALL_PREFIX`: Target installation directory (/opt/develop/root/usr)
- Architecture flags set based on `CMAKE_SYSTEM_PROCESSOR` (lines 27-35)

## Dockerfile Structure

Multi-stage build with 2 stages:

**Stage 1: Build** (lines 1-14)
- Base: `ghcr.io/wangzw/devel-toolchain:latest`
- Mounts source as `/workspace`
- Runs CMake configure, build, install, and strip
- Output: `/opt/develop/root/usr`

**Stage 2: Final** (lines 16-22)
- Base: Same toolchain image
- Copies built libraries from stage 1
- Creates symlink for toolchain file
- Result: Clean image with only installed libraries

## Testing

**This project has NO tests.** It is a build orchestration system, not an application.

- Individual third-party libraries have their own tests (disabled via CMake flags)
- Verification happens through successful Docker image builds in CI/CD
- Manual testing: Build Docker image and use it for C++ development

## CMake Style Guidelines

### File Organization

- Keep `ExternalProject_Add()` definitions in alphabetical order (somewhat followed)
- Group related libraries together when they have dependencies
- Use consistent indentation (4 spaces)

### Adding New Libraries

1. Add `ExternalProject_Add()` entry in `CMakeLists.txt`
2. Follow the common pattern (see above)
3. Set `CMAKE_TOOLCHAIN_FILE` and `CMAKE_INSTALL_PREFIX`
4. Disable tests and docs: `-DBUILD_TESTING:BOOL=OFF`, `-DENABLE_DOCS:BOOL=OFF`
5. Enable static libs: `-DBUILD_SHARED_LIBS:BOOL=OFF`
6. Add `DEPENDS` if the library requires other libraries
7. Use `DOWNLOAD_DIR` to cache downloads in `${CMAKE_SOURCE_DIR}/download/`

### Naming Conventions

- Target names: lowercase with hyphens (e.g., `bzip2-build`, `yaml-cpp`)
- Variables: SCREAMING_SNAKE_CASE (e.g., `DEVELOP_COMPILE_OPTIONS`)
- Paths: Use CMake path variables consistently

### Compiler Flags

Standard flags applied to all libraries (`DEVELOP_COMPILE_OPTIONS`):
```bash
-D_GLIBCXX_USE_CXX11_ABI=1           # Use new C++11 ABI
-ffile-prefix-map=${CMAKE_BINARY_DIR}/src/=   # Reproducible builds
-fdebug-prefix-map=${CMAKE_BINARY_DIR}/src/=  # Reproducible builds
-fPIC                                 # Position-independent code
-march=x86-64-v3                      # x86_64 optimization
-march=armv8.2-a                      # aarch64 optimization
-march=armv8.5-a                      # arm64 optimization
-static-libstdc++ -static-libgcc      # Static linking (Linux/GCC only)
```

## Project Structure

```
devel-image/
├── CMakeLists.txt              # Main build orchestration (1355 lines)
├── Dockerfile                  # Docker image build (22 lines)
├── README.md                   # Minimal documentation
├── LICENSE                     # Apache 2.0
├── cmake/                      # Toolchain configurations
│   ├── build-gcc-toolset-15-toolchain.cmake
│   ├── build-llvm-toolset-20-toolchain.cmake
│   ├── brew-clang-toolchain.cmake
│   ├── devel-toolchain.cmake.in
│   └── homebrew-macos.cmake
├── .github/workflows/
│   └── image.yml              # CI/CD: Multi-platform Docker builds
├── strip-all.sh.in            # Script template for stripping binaries
├── env-wrapper.sh.in          # Script template for environment setup
├── build/                     # Build output (gitignored)
└── download/                  # Downloaded sources (gitignored)
```

**Note:** Subdirectories like `grpc-1.75.1/`, `prometheus-cpp-1.1.0/`, `cctz/`, etc. are third-party dependencies, not project source code.

## CI/CD Pipeline

**File:** `.github/workflows/image.yml`

**Strategy:** Matrix build for multi-architecture support
- Platforms: linux/amd64, linux/arm64
- Runners: ubuntu-24.04 (amd64), ubuntu-24.04-arm (arm64)
- Output: Multi-arch manifest pushed to ghcr.io/wangzw/devel

**Workflow Steps:**
1. Checkout repository
2. Set up Docker Buildx
3. Login to GitHub Container Registry
4. Build and push per-platform images
5. Merge platform digests into multi-arch manifest
6. Tag as `latest` for default branch

**Triggers:**
- Push to tags
- Manual workflow dispatch

## Common Development Tasks

### Adding a New Library Dependency

1. Find library source (GitHub release, Git tag, or tarball URL)
2. Add `ExternalProject_Add()` to CMakeLists.txt following existing pattern
3. Set library-specific CMake options to disable tests/docs, enable static libs
4. If library depends on others, add `DEPENDS <other-library>`
5. Test locally: `cmake --build build --target <library-name>`
6. Commit only CMakeLists.txt changes (not downloaded sources)

### Modifying Build Flags

Edit `DEVELOP_COMPILE_OPTIONS` at CMakeLists.txt:17

### Changing Toolchain

Modify `-DCMAKE_TOOLCHAIN_FILE` in configure command or Dockerfile

### Debugging Build Failures

```bash
# Verbose build output
cmake --build build --verbose

# Build only failing library
cmake --build build --target <library-name>

# Check CMake cache
cmake -L build/

# Clean and rebuild
rm -rf build && cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=... && cmake --build build
```

## Important Notes

- **This is a meta-build system**, not an application with business logic
- All libraries built as **static libraries** by default
- C++20 standard enforced across all dependencies
- Optimized for **x86-64-v3** and **ARM v8.2+** architectures
- Reproducible builds via prefix mapping
- Debug symbols stripped in final Docker image (Linux only)
- No application code style guidelines apply - focus on CMake/Dockerfile clarity
