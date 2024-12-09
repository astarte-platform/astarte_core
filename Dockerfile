FROM hexpm/elixir:1.17.3-erlang-26.1.2-debian-bookworm-20241111-slim as base

# install build dependencies
# --allow-releaseinfo-change allows to pull from 'oldstable'
RUN apt-get update --allow-releaseinfo-change -y && \
    apt-get install -y \
    build-essential \
    git \
    openssl \
    erlang-dev \
    ca-certificates \
    inotify-tools && \
    apt-get clean && \
    rm -f /var/lib/apt/lists/*_*

# Install hex
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

WORKDIR /src

FROM base as deps

ARG BUILD_ENV=prod

ENV MIX_ENV=${BUILD_ENV}

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get --only ${MIX_ENV}, deps.compile

FROM deps as builder

ENV MIX_ENV=${BUILD_ENV}

# Add all the rest
ADD . .
ENTRYPOINT [ "/bin/sh", "-c" ]
# ------------------------
# Only for production
FROM builder as release

ENV MIX_ENV=${BUILD_ENV}

COPY --from=builder /src .

WORKDIR /src
RUN mix do compile, release
