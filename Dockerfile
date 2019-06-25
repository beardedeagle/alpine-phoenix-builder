FROM alpine:3.9.4 as base_stage

LABEL maintainer="beardedeagle <randy@heroictek.com>"

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images.
ENV REFRESHED_AT=2019-06-24 \
  MIX_HOME=/usr/local/lib/elixir/.mix \
  TERM=xterm \
  LANG=C.UTF-8

RUN set -xe \
  && apk --update --no-cache upgrade \
  && apk add --no-cache \
    bash \
    libstdc++ \
    lksctp-tools \
    openssl \
  && rm -rf /root/.cache \
  && rm -rf /var/cache/apk/*

FROM base_stage as deps_stage

RUN set -xe \
  && apk add --no-cache --virtual .build-deps rsync

FROM beardedeagle/alpine-elixir-builder:1.9.0 as elixir_stage

FROM beardedeagle/alpine-node-builder:12.4.0 as node_stage

FROM deps_stage as stage

COPY --from=elixir_stage /usr/local /opt/elixir
COPY --from=node_stage /usr/local /opt/node

RUN set -xe \
  && rsync -a /opt/elixir/ /usr/local \
  && rsync -a /opt/node/ /usr/local \
  && apk del .build-deps \
  && rm -rf /root/.cache \
  && rm -rf /var/cache/apk/*

FROM base_stage

COPY --from=stage /usr/local /usr/local
