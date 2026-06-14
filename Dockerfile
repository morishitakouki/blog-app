# syntax = docker/dockerfile:1

# =============================================================
# 開発用・本番用を1つにまとめた Dockerfile
#   開発: docker compose up                （target: development）
#   本番: docker build --target production .（target: production）
# =============================================================

ARG RUBY_VERSION=3.4.1
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

# Rails アプリの作業ディレクトリ
WORKDIR /rails

# gem の保存先（開発・本番共通）
ENV BUNDLE_PATH="/usr/local/bundle"


# -------------------------------------------------------------
# development: 開発用ステージ
#   コードは docker-compose のボリュームでマウントする想定
# -------------------------------------------------------------
FROM base AS development

ENV RAILS_ENV="development"

# gem のビルド・実行に必要なパッケージ
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libvips \
      libsqlite3-0 \
      pkg-config && \
    rm -rf /var/lib/apt/lists/*

# 先に Gemfile だけコピーして bundle install（キャッシュを効かせる）
COPY Gemfile Gemfile.lock ./
RUN bundle install

EXPOSE 3000
# 実際の起動コマンドは docker-compose.yml 側で指定する
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]


# -------------------------------------------------------------
# build: 本番イメージを作るための一時ステージ（成果物だけ後で使う）
# -------------------------------------------------------------
FROM base AS build

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development"

# gem のビルドに必要なパッケージ
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config

# 本番用 gem をインストール
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# アプリケーションコードをコピー
COPY . .

# 起動高速化のためのプリコンパイル
RUN bundle exec bootsnap precompile app/ lib/

# Windows で生成された binstub を Linux で動くように修正
# （改行コード CRLF→LF、シバンの ruby.exe→ruby）
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# RAILS_MASTER_KEY 無しでアセットをプリコンパイル
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# -------------------------------------------------------------
# production: 本番用の最終イメージ（軽量・非rootユーザー）
# -------------------------------------------------------------
FROM base AS production

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development"

# 実行に必要な最小限のパッケージ
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 libvips && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# build ステージから成果物（gem・アプリ）をコピー
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# 非 root ユーザーで実行（セキュリティ）
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# エントリポイントで DB を準備
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["./bin/rails", "server"]
