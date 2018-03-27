FROM ruby:2.3.6-alpine

LABEL maintainer="Savedo GmbH <it@savedo.de>"

ENV APP_HOME=/usr/src/app

RUN apk update \
    && apk upgrade \
    && apk add --upgrade build-base libxml2-dev libxslt-dev \
    && rm -rf /var/cache/apk/*

WORKDIR $APP_HOME

RUN mkdir -p $APP_HOME
RUN mkdir -p $APP_HOME/lib/service_logging

COPY Gemfile $APP_HOME/
COPY service_logging.gemspec $APP_HOME/
COPY lib/service_logging/version.rb $APP_HOME/lib/service_logging/

RUN bundle config build.nokogiri --use-system-libraries \
    && bundle install \
    && bundle clean

COPY . $APP_HOME/
