# Docker + Alpine + Elixir && Phoenix = Love

This Dockerfile provides a good base build image to use in multistage builds for Elixir and Phoenix apps. It comes with the latest version of Alpine, Erlang, Elixir, Rebar, Hex, NodeJS and NPM. It is intended for use in creating release images with or for your application and allows you to avoid cross-compiling releases. The exception of course is if your app has NIFs which require a native compilation toolchain, but that is left as an exercise let to the user.

No effort has been made to make this image suitable to run in unprivileged environments. The repository owner is not responsible for any losses that result from improper usage or security practices, as it is expected that the user of this image will implement proper security practices themselves.

## Software/Language Versions

```shell
Alpine 3.9
OTP/Erlang 22.0
Elixir 1.8.2
Rebar 3.10.0
Hex 0.19.0
Nodejs 12.2.0
NPM 6.9.0
```

## Usage

To boot straight to a iex prompt in the image:

```shell
$ docker run --rm -i -t beardedeagle/alpine-phoenix-builder iex
Erlang/OTP 22 [erts-10.4] [source] [64-bit] [smp:6:6] [ds:6:6:10] [async-threads:1] [hipe]

Interactive Elixir (1.8.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

For your own application:

```dockerfile
FROM beardedeagle/alpine-phoenix-builder:1.8.2 as builder
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

FROM alpine:3.9
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
