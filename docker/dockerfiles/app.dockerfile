ARG RUBY_VERSION=3.2.4
ARG DEBIAN_VERSION=bullseye

FROM ruby:$RUBY_VERSION-slim-$DEBIAN_VERSION as base

ARG USER=appuser
ARG GROUP=appuser
ARG USER_ID
ARG GROUP_ID

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
  groupadd -g ${GROUP_ID} ${GROUP} &&\
  useradd -u ${USER_ID} -g ${GROUP} -s /bin/sh -m ${USER} \
;fi

ARG APP_HOME="/usr/src/app"

RUN mkdir -p ${APP_HOME} && \
    chown -R ${USER}:${GROUP} ${APP_HOME}

# General dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

ARG RUBYGEMS_VERSION
ENV RUBYGEMS_VERSION ${RUBYGEMS_VERSION:-3.5.9}

RUN gem update --system $RUBYGEMS_VERSION
RUN chown -R ${USER}:${GROUP} /usr/local/bundle

# Application dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    vim \
    # nokogiri dependencies
    liblzma-dev \
    patch \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

USER ${USER}
WORKDIR ${APP_HOME}

FROM base as development

ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV}
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

COPY --chown=${USER}:${GROUP} ./Gemfile* ${APP_HOME}

RUN bundle check || bundle install --jobs 4 --retry 3

COPY --chown=${USER}:${GROUP} . ${APP_HOME}

RUN RAILS_ENV=development NODE_ENV=development bundle exec rails assets:precompile

COPY --chown=${USER}:${GROUP} ./docker/entrypoints/development/app-entrypoint.sh /docker/entrypoints/app-entrypoint.sh
RUN chmod +x /docker/entrypoints/app-entrypoint.sh

FROM base as production

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true
ARG ACTION_CABLE_ALLOWED_REQUEST_ORIGINS
ENV ACTION_CABLE_ALLOWED_REQUEST_ORIGINS=${ACTION_CABLE_ALLOWED_REQUEST_ORIGINS}
ARG RAILS_MASTER_KEY

COPY --chown=${USER}:${GROUP} ./Gemfile* /usr/src/app/

RUN bundle config set without "development test"
RUN bundle install --jobs 4 --retry 3

COPY --chown=${USER}:${GROUP} . ${APP_HOME}

RUN rm -rf public/assets public/packs

RUN RAILS_ENV=production NODE_ENV=production SECRET_KEY_BASE=1 bundle exec rails assets:precompile

COPY --chown=${USER}:${GROUP} ./docker/entrypoints/production/app-entrypoint.sh /docker/entrypoints/app-entrypoint.sh
RUN chmod +x /docker/entrypoints/app-entrypoint.sh
