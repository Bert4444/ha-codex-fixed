ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG TTYD_VERSION

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color \
    PATH=/root/.local/bin:${PATH}

# Codex itself is installed with OpenAI's Linux installer. ttyd provides the
# terminal that Home Assistant exposes through Ingress.
RUN apk add --no-cache \
      bash \
      ca-certificates \
      curl \
      git \
      jq \
      ripgrep \
      tmux \
  && update-ca-certificates \
  && curl -fsSL "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.x86_64" -o /usr/local/bin/ttyd \
  && chmod 0755 /usr/local/bin/ttyd \
  && curl -fsSL https://chatgpt.com/codex/install.sh | sh \
  && codex --version

COPY run.sh /run.sh
RUN chmod 0755 /run.sh \
  && mkdir -p /homeassistant /config/codex

WORKDIR /homeassistant

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD curl --fail --silent http://127.0.0.1:7681/ >/dev/null || exit 1

CMD [ "/run.sh" ]
