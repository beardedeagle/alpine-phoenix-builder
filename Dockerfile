FROM alpine:3.12.1 as base_stage

LABEL maintainer="beardedeagle <randy@heroictek.com>"

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images.
ENV REFRESHED_AT=2020-10-23 \
  MIX_HOME=/usr/local/lib/elixir/.mix \
  TERM=xterm \
  LANG=C.UTF-8

RUN set -xe \
  && apk --no-cache update \
  && apk --no-cache upgrade \
  && apk add --no-cache bash git libstdc++ openssl zlib \
  && rm -rf /root/.cache \
  && rm -rf /var/cache/apk/*

FROM base_stage as deps_stage

RUN set -xe \
  && apk add --no-cache --virtual .build-deps rsync

FROM beardedeagle/alpine-elixir-builder:1.11.1 as elixir_stage

FROM beardedeagle/alpine-node-builder:15.0.1 as node_stage

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
