FROM ubuntu:16.04

ENV BUNDLE_PATH /bundle

RUN apt-get -y update && apt-get -y install --no-install-recommends build-essential \
ca-certificates chrpath git-core libssl-dev libcurl3-openssl-dev vim \
libexpat1-dev libffi-dev libreadline-dev libsqlite-dev libxml2-dev \
libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev \
libgconf-2-4 libxi6 libxslt-dev libxslt1-dev  libyaml-dev locales \
openjdk-8-jre-headless nodejs unzip wget xvfb && \
locale-gen en_US.UTF-8 && \
export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8 && \
wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.4.tar.gz && \
tar -xzf ruby-2.3.4.tar.gz && \
cd ruby-2.3.4 && ./configure --with-out-ext=tcl --with-out-ext=tk --disable-install-doc && make && make install && \
make clean && cd .. && \
rm -rf ruby-2.3.4.tar.gz && rm -rf ruby-2.3.4 && \
touch /etc/apt/sources.list.d/pgdg.list && \
echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' | tee -a /etc/apt/sources.list.d/pgdg.list && \
wget --quiet https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
apt-key add ACCC4CF8.asc && \
rm -f ACCC4CF8.asc && \
apt-get -y update && \
apt-get -y install --no-install-recommends libpq-dev postgresql-server-dev-9.6 postgresql-client-9.6 && \
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
mkdir -p /app && mkdir -p /bundle && useradd -U -m app

# Pinned versions are specific to one of the applications I'm using this image
# in. I'm installing all of the gems that have native extensions just to make
# sure everything works
RUN gem update -N --system && gem install -N bundler:1.15.4 rake brakeman rubocop

# Pinned versions are specific to one of the applications I'm using this image
# in. I'm installing all of the gems that have native extensions just to make
# sure everything works
#
# Installing these via bundler, trading a larger image size for speed when
# running bundle install in an application. This may change
RUN echo "source 'https://rubygems.org'\nruby '~> 2.3.4'\ngem 'pg'\ngem 'nokogiri', '1.8.0'\ngem 'selenium-webdriver', '2.53.4'\ngem 'binding_of_caller'\ngem 'nio4r'\ngem 'websocket-driver', '0.6.5'\ngem 'rainbow'\ngem 'raindrops'\ngem 'ffi'\ngem 'eventmachine'\ngem 'http_parser.rb'\ngem 'debug_inspector'\ngem 'byebug'\ngem 'puma'\ngem 'kgio'\ngem 'unicorn', '5.3.0'\ngem 'selenium-webdriver', '2.53.4'" > Gemfile && \
bundle install --jobs=4 --retry=3 --quiet && rm Gemfile*

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

WORKDIR /app

LABEL maintainer="Jay Dorsey <jay@arcadiapower.com>" \
version="0.0.1" \
description="Ubuntu Ruby 2.3.4 base image for Ruby on Rails work"
