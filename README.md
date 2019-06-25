# Docker + Alpine + Elixir && Phoenix = Love

This Dockerfile provides a good base build image to use in multistage builds for Elixir and Phoenix apps. It comes with the latest version of Alpine, Erlang, Elixir, Rebar, Hex, NodeJS and NPM. It is intended for use in creating release images with or for your application and allows you to avoid cross-compiling releases. The exception of course is if your app has NIFs which require a native compilation toolchain, but that is an exercise left to the user.

No effort has been made to make this image suitable to run in unprivileged environments. The repository owner is not responsible for any losses that result from improper usage or security practices, as it is expected that the user of this image will implement proper security practices themselves.

## Software/Language Versions

```shell
Alpine 3.9.4
OTP/Erlang 22.0.4
Elixir 1.9.0
Rebar 3.11.1
Hex 0.20.1
Nodejs 12.4.0
NPM 6.9.0
```

## Usage

To boot straight to a iex prompt in the image:

```shell
$ docker run --rm -i -t beardedeagle/alpine-phoenix-builder iex
Erlang/OTP 22 [erts-10.4.3] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

Interactive Elixir (1.9.0) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

For your own application:

- Using Elixir releases

```dockerfile
FROM beardedeagle/alpine-phoenix-builder:1.9.0 as builder
ENV appdir /opt/test_app
WORKDIR ${appdir}
COPY . ${appdir}
RUN mix deps.get --only prod \
  && MIX_ENV=prod mix compile \
  && cd assets \
  && npm install \
  && node node_modules/webpack/bin/webpack.js --mode production \
  && cd ${appdir} \
  && MIX_ENV=prod mix phx.digest \
  && MIX_ENV=prod mix release \
  && V=0.1.0; pushd _build/prod/rel; tar -czvf ${appdir}/test_app-${V}.tar.gz test_app; popd;

FROM alpine:3.9.4
EXPOSE 4000
ENV appver 0.1.0
WORKDIR /opt/test_app
COPY --from=builder /opt/test_app/test_app-${appver}.tar.gz .
RUN apk add --no-cache bash libressl \
  && tar -xzvf test_app-${appver}.tar.gz \
  && rm -rf test_app-${appver}.tar.gz \
  && rm -rf /root/.cache \
  && rm -rf /var/cache/apk/*
CMD ["bin/test_app", "start"]
```

- Using Distillery

```dockerfile
FROM beardedeagle/alpine-phoenix-builder:1.9.0 as builder
ENV appdir /opt/test_app
WORKDIR ${appdir}
COPY . ${appdir}
RUN mix deps.get --only prod \
  && MIX_ENV=prod mix compile \
  && cd assets \
  && npm install \
  && node node_modules/webpack/bin/webpack.js --mode production \
  && cd ${appdir} \
  && MIX_ENV=prod mix phx.digest \
  && MIX_ENV=prod mix release --env=prod

FROM alpine:3.9.4
EXPOSE 4000
ENV appver 0.1.0
WORKDIR /opt/test_app
COPY --from=builder /opt/test_app/_build/prod/rel/test_app/releases/${appver}/test_app.tar.gz .
RUN apk add --no-cache bash libressl \
  && tar -xzvf test_app.tar.gz \
  && rm -rf test_app.tar.gz \
  && rm -rf /root/.cache \
  && rm -rf /var/cache/apk/*
CMD ["bin/test_app", "foreground"]
```

## History

The code provided by PR [#1][1] is MIT licensed by GoDaddy. Any code changes after that are MIT licensed by the repository owner.

[1]: https://github.com/beardedeagle/alpine-phoenix-builder/pull/1
