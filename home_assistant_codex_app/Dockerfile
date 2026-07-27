ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG TTYD_VERSION

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color

# Codex itself is installed with OpenAI's Linux installer. ttyd provides the
# terminal that Home Assistant exposes through Ingress.
RUN apk add --no-cache \
      bash \
      bubblewrap \
      ca-certificates \
      curl \
      git \
      grep \
      gzip \
      jq \
      ripgrep \
      tmux \
  && update-ca-certificates \
  && curl -fsSL "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.x86_64" -o /usr/local/bin/ttyd \
  && chmod 0755 /usr/local/bin/ttyd \
  && curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_HOME=/opt/codex CODEX_INSTALL_DIR=/usr/local/bin CODEX_NON_INTERACTIVE=1 sh \
  && codex --version

COPY run.sh /run.sh
COPY session.sh /usr/local/bin/ha-codex-session
RUN chmod 0755 /run.sh /usr/local/bin/ha-codex-session \
  && mkdir -p /homeassistant /config/codex /opt/codex

WORKDIR /homeassistant

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD curl --fail --silent http://127.0.0.1:7681/ >/dev/null || exit 1

CMD [ "/run.sh" ]
