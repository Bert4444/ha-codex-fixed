ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG TTYD_VERSION
ARG TRZSZ_VERSION
ARG CODEX_VERSION
ARG BUILD_ARCH

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color

# Codex is installed from a pinned GitHub release (CODEX_VERSION) rather than
# the always-latest installer, so a new Codex release cannot change the app's
# behaviour until the pin is bumped.
#
# BUILD_ARCH is supplied by the Home Assistant app build system.
# This Dockerfile supports:
#   amd64   -> Intel / AMD Home Assistant machines
#   aarch64 -> Raspberry Pi 5 / ARM64 machines
#
# ttyd provides the terminal exposed through Home Assistant Ingress.
# trzsz supplies browser-friendly file transfer support.
# Python + PyYAML are included for Home Assistant YAML/config analysis.
# codex-code-mode-host is installed alongside Codex for code-mode support.

RUN set -eux; \
    case "${BUILD_ARCH}" in \
      amd64) \
        TTYD_ARCH="x86_64"; \
        TRZSZ_ARCH="x86_64"; \
        CODEX_TARGET="x86_64-unknown-linux-musl"; \
        ;; \
      aarch64) \
        TTYD_ARCH="aarch64"; \
        TRZSZ_ARCH="aarch64"; \
        CODEX_TARGET="aarch64-unknown-linux-musl"; \
        ;; \
      *) \
        echo "Unsupported architecture: ${BUILD_ARCH}"; \
        exit 1; \
        ;; \
    esac; \
    \
    echo "Building HA Codex for ${BUILD_ARCH}"; \
    echo "Codex target: ${CODEX_TARGET}"; \
    \
    apk add --no-cache \
      bash \
      bubblewrap \
      ca-certificates \
      curl \
      git \
      grep \
      gzip \
      jq \
      python3 \
      py3-yaml \
      ripgrep \
      tar \
      tmux; \
    \
    update-ca-certificates; \
    \
    curl -fsSL \
      "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${TTYD_ARCH}" \
      -o /usr/local/bin/ttyd; \
    chmod 0755 /usr/local/bin/ttyd; \
    \
    curl -fsSL \
      "https://github.com/trzsz/trzsz-go/releases/download/v${TRZSZ_VERSION}/trzsz_${TRZSZ_VERSION}_linux_${TRZSZ_ARCH}.tar.gz" \
      -o /tmp/trzsz.tar.gz; \
    mkdir -p /tmp/trzsz; \
    tar -xzf /tmp/trzsz.tar.gz -C /tmp/trzsz; \
    find /tmp/trzsz -type f \( -name trz -o -name tsz -o -name trzsz \) \
      -exec install -m 0755 {} /usr/local/bin/ \;; \
    rm -rf /tmp/trzsz /tmp/trzsz.tar.gz; \
    trz --version; \
    \
    curl -fsSL \
      "https://github.com/openai/codex/releases/download/rust-v${CODEX_VERSION}/codex-${CODEX_TARGET}.tar.gz" \
      -o /tmp/codex.tar.gz; \
    mkdir -p /tmp/codex; \
    tar -xzf /tmp/codex.tar.gz -C /tmp/codex; \
    install -m 0755 \
      "$(find /tmp/codex -type f -name 'codex*' ! -name '*code-mode-host*' ! -name '*.sigstore' | head -n 1)" \
      /usr/local/bin/codex; \
    rm -rf /tmp/codex /tmp/codex.tar.gz; \
    \
    curl -fsSL \
      "https://github.com/openai/codex/releases/download/rust-v${CODEX_VERSION}/codex-code-mode-host-${CODEX_TARGET}.tar.gz" \
      -o /tmp/codex-host.tar.gz; \
    mkdir -p /tmp/codex-host; \
    tar -xzf /tmp/codex-host.tar.gz -C /tmp/codex-host; \
    install -m 0755 \
      "$(find /tmp/codex-host -type f -name 'codex-code-mode-host*' ! -name '*.sigstore' | head -n 1)" \
      /usr/local/bin/codex-code-mode-host; \
    rm -rf /tmp/codex-host /tmp/codex-host.tar.gz; \
    \
    codex --version; \
    python3 --version; \
    python3 -c "import yaml; print('PyYAML OK:', yaml.__version__)"; \
    test -x /usr/local/bin/codex-code-mode-host; \
    ttyd --version

COPY run.sh /run.sh
COPY session.sh /usr/local/bin/ha-codex-session
COPY ha-codex-ha /usr/local/bin/ha-codex-ha
COPY tmux.conf /etc/ha-codex-tmux.conf

RUN chmod 0755 \
      /run.sh \
      /usr/local/bin/ha-codex-session \
      /usr/local/bin/ha-codex-ha \
      /usr/local/bin/codex \
      /usr/local/bin/codex-code-mode-host \
  && mkdir -p /homeassistant /config/codex

WORKDIR /homeassistant

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD curl --fail --silent http://127.0.0.1:7681/ >/dev/null || exit 1

CMD ["/run.sh"]
