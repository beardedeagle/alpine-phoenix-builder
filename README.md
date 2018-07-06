# Docker + Alpine + Elixir && Phoenix = Love

This Dockerfile provides a good base build image to use in multistage builds for Elixir and Phoenix apps.
It comes with the latest version of Erlang, Elixir, Rebar, Hex, NodeJS and NPM. It is intended for use
in creating release images with or for your application.

No effort has been made to make this image suitable to run in unprivileged environments. It is expected
the user of this image will implement proper security practices themselves.

## Usage

To boot straight to a iex prompt in the image:

```shell
$ docker run --rm -i -t beardedeagle/alpine-phoenix-builder iex
Erlang/OTP 21 [erts-10.0.2] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

Interactive Elixir (1.6.6) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

For your own application:

```dockerfile
FROM beardedeagle/alpine-phoenix-builder:1.6.6 as builder
ENV appdir /opt/test_app
WORKDIR ${appdir}
COPY . ${appdir}
RUN mix deps.get --only prod \
  && MIX_ENV=prod mix compile \
  && cd assets \
  && npm install \
  && node node_modules/brunch/bin/brunch build --production \
  && cd ${appdir} \
  && MIX_ENV=prod mix phx.digest \
  && MIX_ENV=prod mix release --env=prod

FROM alpine:3.7
EXPOSE 4000
ENV appver 0.0.1
WORKDIR /opt/test_app
COPY --from=builder /opt/test_app/_build/prod/rel/test_app/releases/${appver}/test_app.tar.gz .
RUN apk add --no-cache bash openssl \
  && tar -xzvf test_app.tar.gz \
  && rm -rf test_app.tar.gz \
  && rm -rf /root/.cache \
  && rm -rf /var/cache/apk/*
CMD ["bin/test_app", "foreground"]
```

## History

The code provided by PR [#1][1] is MIT licensed by GoDaddy. Any code changes after that are MIT
licensed by the repository owner.

[1]: https://github.com/beardedeagle/alpine-phoenix-builder/pull/1
