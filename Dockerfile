ARG LIBRARIES_TAG=latest
ARG TARGETARCH

FROM ghcr.io/wangzw/devel-libraries:${LIBRARIES_TAG} AS libraries

FROM ghcr.io/wangzw/devel-toolchain:latest
LABEL authors="Zhanwei Wang"

COPY --from=libraries /opt/develop /opt/develop

RUN ln -s /opt/develop/root/usr/devel-toolchain.cmake /opt/devel-toolchain.cmake

RUN <<'EOF'
dnf -y install epel-release && dnf -y update
dnf -y install --allowerasing curl

dnf -y install          \
    bat                 \
    bind-utils          \
    binutils            \
    btop                \
    ca-certificates     \
    fd-find             \
    fzf                 \
    gh                  \
    git-delta           \
    gperf               \
    groff-base          \
    hostname            \
    htop                \
    iproute             \
    iputils             \
    jq                  \
    less                \
    lsof                \
    ltrace              \
    man-db              \
    nano                \
    ncdu                \
    net-tools           \
    nmap-ncat           \
    nmon                \
    nodejs              \
    openssl             \
    p7zip               \
    perf                \
    psmisc              \
    ripgrep             \
    rsync               \
    shadow-utils        \
    shellcheck          \
    socat               \
    strace              \
    sysstat             \
    tcpdump             \
    tree                \
    unzip               \
    valgrind            \
    wget                \
    yq

dnf clean all
rm -rf /var/cache/dnf
EOF

RUN npm install -g opencode-ai
