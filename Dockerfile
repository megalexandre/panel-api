# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.4.2
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Instalamos apenas o essencial para RODAR o app
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    # libpq5 é a biblioteca runtime do postgres (essencial para a gem 'pg')
    libpq5 \
    # Cliente padrão do Debian (versão 15 geralmente, que funciona perfeitamente com o PG 17)
    postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Configurações de ambiente
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test:tools" \
    LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libjemalloc.so.2"

# --- Estágio de Build ---
FROM base AS build

# Instalamos o que é necessário para COMPILAR as gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    libyaml-dev \
    pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    # Remove cache de gems e arquivos de objeto (.o) que sobram da compilação
    rm -rf "${BUNDLE_PATH}"/cache/*.gem && \
    find "${BUNDLE_PATH}"/ruby/*/gems/ -name "*.o" -delete

COPY . .

# Precompila o bootsnap
RUN bundle exec bootsnap precompile -j 1 app/ lib/

# --- Estágio Final ---
FROM base

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

# Copia apenas o que importa
COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

# Limpeza final de pastas desnecessárias que podem ter vindo no 'COPY .'
RUN rm -rf /rails/tmp/* /rails/log/* /rails/spec /rails/test /rails/.git

USER 1000:1000
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]