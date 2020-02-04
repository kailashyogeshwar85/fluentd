FROM fluent/fluentd:v1.4-1
LABEL MAINTAINER=KailashYogeshwar<kailashyogeshwar85@gmail.com>

USER root

ENV PATH /fluentd/vendor/bundle/ruby/2.5.0/bin:$PATH
ENV GEM_PATH /fluentd/vendor/bundle/ruby/2.5.0
ENV GEM_HOME /fluentd/vendor/bundle/ruby/2.5.0

RUN mkdir /fluentd/vendor && mkdir /fluentd/vendor/bundle;


# Configs mounted for HMR
COPY ./Gemfile /fluentd/etc/Gemfile
# COPY ./configs.d /configs.d

RUN apk add --no-cache --update --virtual .build-deps \
        sudo build-base ruby-dev bash libffi-dev \
 # cutomize following instruction as you wish
 && sudo gem sources --clear-all \
#  && apk del .build-deps \
 && gem install bundler --version 1.16.2 --no-document  \
 && bundler config silence_root_warning true \
 && bundler install --path=/fluentd/vendor/bundle --gemfile=/fluentd/etc/Gemfile \
 && rm -rf /home/fluent/.gem/ruby/2.5.0/cache/*.gem

COPY fluent.conf /fluentd/etc/
COPY entrypoint.sh /bin/
RUN chmod +x /bin/entrypoint.sh
USER fluent