# vi: filetype=dockerfile
FROM ubuntu:16.04

RUN apt-get -y update && apt-get -y install --no-install-recommends build-essential \
ca-certificates chrpath git-core libssl-dev libcurl3-openssl-dev vim \
libexpat1-dev libffi-dev libreadline-dev libsqlite-dev libxml2-dev \
libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev \
libgconf-2-4 libxi6 libxslt-dev libxslt1-dev  libyaml-dev locales \
openjdk-8-jre-headless nodejs unzip wget xvfb && \
locale-gen en_US.UTF-8 && \
export BUNDLE_PATH=/bundle && export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8 && \
wget https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.1.tar.gz && \
tar -xzf ruby-2.4.1.tar.gz && \
cd ruby-2.4.1 && ./configure --with-out-ext=tcl --with-out-ext=tk --disable-install-doc && make && make install && \
make clean && cd .. && \
rm -rf ruby-2.4.1.tar.gz && rm -rf ruby-2.4.1 && \
touch /etc/apt/sources.list.d/pgdg.list && \
echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' | tee -a /etc/apt/sources.list.d/pgdg.list && \
wget --quiet https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
apt-key add ACCC4CF8.asc && \
rm -f ACCC4CF8.asc && \
apt-get -y update \
&& apt-get -y install --no-install-recommends libpq-dev postgresql-server-dev-9.6 postgresql-client-9.6 \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
&& useradd -U -m app

RUN export PHANTOM_JS="phantomjs-2.1.1-linux-x86_64" && \
wget -q https://github.com/Medium/phantomjs/releases/download/v2.1.1/$PHANTOM_JS.tar.bz2 && \
tar xvjf $PHANTOM_JS.tar.bz2 && \
mv $PHANTOM_JS /usr/local/share && \
ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin && \
rm $PHANTOM_JS.tar.bz2

ENV CHROME_DRIVER_VERSION 2.35
ENV SELENIUM_STANDALONE_VERSION 3.8.1

# Install Google Chrome Stable
# NOTE: we don't actually use this package but we want to get it's dependencies
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list && \
  apt-get update -y && \
  apt-get install -y google-chrome-stable

# At the time of writing this installs 65.0.3325.31-1, which we need since it supports the
# --disable-dev-shm-usage flag, and the stable builds do not. Once stable main catches up,
# we can axe this whole stanza
RUN export CHROME_PACKAGE="google-chrome-unstable_current_amd64.deb" && \
  wget -q https://dl.google.com/linux/direct/$CHROME_PACKAGE && \
  dpkg -i $CHROME_PACKAGE && \
  # No need for downstream apps to know
  rm -rf /opt/google/chrome && \
  mv /opt/google/chrome-unstable /opt/google/chrome && \
  rm $CHROME_PACKAGE

# Install ChromeDriver.
RUN wget -N http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -P ~/ && \
unzip ~/chromedriver_linux64.zip -d ~/ && \
rm ~/chromedriver_linux64.zip && \
mv -f ~/chromedriver /usr/local/bin/chromedriver && \
chown root:root /usr/local/bin/chromedriver && \
chmod 0755 /usr/local/bin/chromedriver

# Install Selenium.
RUN export SELENIUM_SUBDIR=$(echo "$SELENIUM_STANDALONE_VERSION" | cut -d"." -f-2) && \
wget -N http://selenium-release.storage.googleapis.com/$SELENIUM_SUBDIR/selenium-server-standalone-$SELENIUM_STANDALONE_VERSION.jar -P ~/ && \
mv -f ~/selenium-server-standalone-$SELENIUM_STANDALONE_VERSION.jar /usr/local/bin/selenium-server-standalone.jar && \
chown root:root /usr/local/bin/selenium-server-standalone.jar && \
chmod 0755 /usr/local/bin/selenium-server-standalone.jar

# Pinned versions are specific to one of the applications I'm using this image
# in. I'm installing all of the gems that have native extensions just to make
# sure everything works
#
# Installing these via bundler, trading a larger image size for speed when
# running bundle install in an application. This may change

ENV LC_ALL=en_US.UTF-8 \
LANG=en_US.UTF-8 \
LANGUAGE=en_US.UTF-8 \
BUNDLE_PATH=/bundle \
BUNDLE_DISABLE_SHARED_GEMS="1"

WORKDIR /app

LABEL maintainer="Jay Dorsey <jay@arcadiapower.com>" \
version="0.0.1" \
description="Ubuntu Ruby 2.4.1 base image for Ruby on Rails work"
