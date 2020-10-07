FROM elixir:1.10

RUN apt-get update && apt-get install -y \
      build-essential \
      nodejs \
      npm

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets install

CMD ["mix", "phx.server"]

