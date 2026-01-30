# C++ Development Environment

## CI/CD Pipeline

This project uses a two-stage CI/CD pipeline to build and publish Docker images:

### 1. Build Libraries Workflow (`.github/workflows/build-libraries.yml`)

**Trigger:** Manual only via GitHub Actions

Builds all third-party libraries and packages them as `ghcr.io/wangzw/devel-libraries`.

```bash
# Manually trigger via GitHub UI or CLI
gh workflow run build-libraries.yml
```

### 2. Build Image Workflow (`.github/workflows/build-image.yml`)

**Triggers:**
- Push tags (e.g., `v1.0.0`)
- Manual trigger with optional `libraries_tag` parameter

Builds the final development image from the pre-built libraries package.

```bash
# Use latest libraries
gh workflow run build-image.yml

# Use specific libraries tag
gh workflow run build-image.yml -f libraries_tag=sha-abc123
```

### Image Registry

- **Libraries Package:** `ghcr.io/wangzw/devel-libraries`
- **Final Image:** `ghcr.io/wangzw/devel`

## On Macos

```bash
brew install autoconf autoconf-archive automake flex bison
```
