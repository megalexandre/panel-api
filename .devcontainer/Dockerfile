FROM mcr.microsoft.com/devcontainers/base:bookworm

ARG RUBY_VERSION=3.4.2

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        bison \
        build-essential \
        ca-certificates \
        curl \
        git \
        libdb-dev \
        libffi-dev \
        libpq-dev \
        libgdbm-dev \
        libgmp-dev \
        libncurses5-dev \
        libreadline-dev \
        libssl-dev \
        libyaml-dev \
        pkg-config \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg \
    && apt-get update \
    && apt-get install -y --no-install-recommends postgresql-client-17 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://cache.ruby-lang.org/pub/ruby/${RUBY_VERSION%.*}/ruby-${RUBY_VERSION}.tar.gz" -o /tmp/ruby.tar.gz \
    && tar -xzf /tmp/ruby.tar.gz -C /tmp \
    && cd "/tmp/ruby-${RUBY_VERSION}" \
    && ./configure --disable-install-doc \
    && make -j"$(nproc)" \
    && make install \
    && rm -rf /tmp/ruby.tar.gz "/tmp/ruby-${RUBY_VERSION}"

RUN gem update --system \
    && gem install bundler -N \
    && gem install rails -N \
    && chown -R vscode:vscode /usr/local/lib/ruby/gems

USER vscode
