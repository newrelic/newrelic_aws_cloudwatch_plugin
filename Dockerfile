FROM debian:stretch-slim
WORKDIR /usr/local/newrelic_aws_cloudwatch_plugin-latest

RUN DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get install -qy --no-install-recommends build-essential curl ruby-dev libxml2-dev libxslt-dev ruby && \
  apt-get autoremove --purge && \
  apt-get clean

COPY . .

RUN gem install --no-rdoc --no-ri bundler

RUN bundle install --quiet --without test && \
  bundle clean --force && \
  apt-get remove -yq --purge build-essential curl ruby-dev libxml2-dev libxslt-dev && \
  apt-get autoremove -yq --purge && \
  rm -rf latest.tar.gz /tmp/* /var/tmp/* /var/lib/apt/lists/*

ADD newrelic_plugin.yml config/

ENTRYPOINT ["bundle", "exec", "./bin/newrelic_aws"]
