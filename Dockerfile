FROM elixir:1.10-alpine

# install build dependencies
RUN apk add --no-cache \
    build-base \
    npm \
    git \
    python \
    ncurses-libs

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

RUN mix do deps.get

# # build assets
# COPY assets/package.json assets/package-lock.json ./assets/
# RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

CMD ["mix", "phx.server"]

