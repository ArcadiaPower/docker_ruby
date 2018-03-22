# vi: filetype=dockerfile
FROM ruby:2.4.3

ENV CHROME_DRIVER_VERSION 2.35
ENV SELENIUM_STANDALONE_VERSION 3.8.1

RUN apt-get -y update && apt-get -y install --no-install-recommends build-essential \
ca-certificates chrpath git-core libssl-dev libcurl3-openssl-dev vim \
libexpat1-dev libffi-dev libreadline-dev libxml2-dev \
libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev \
libgconf-2-4 libxi6 libxslt-dev libxslt1-dev  libyaml-dev locales tesseract-ocr imagemagick ghostscript \
nodejs unzip wget xvfb && \
locale-gen en_US.UTF-8 && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
useradd -U -m app

RUN export PHANTOM_JS="phantomjs-2.1.1-linux-x86_64" && \
wget -q https://github.com/Medium/phantomjs/releases/download/v2.1.1/$PHANTOM_JS.tar.bz2 && \
tar xvjf $PHANTOM_JS.tar.bz2 && \
mv $PHANTOM_JS /usr/local/share && \
ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin && \
rm $PHANTOM_JS.tar.bz2

# Install Google Chrome Stable
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list && \
  apt-get update -y && \
  apt-get install -y google-chrome-stable

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

ENV LC_ALL=en_US.UTF-8 \
LANG=en_US.UTF-8 \
LANGUAGE=en_US.UTF-8

WORKDIR /app

LABEL maintainer="Arcadia Power Engineering <engineering@arcadiapower.com>" \
version="0.1" \
description="Ubuntu Ruby 2.4.1 base image for Ruby on Rails work"
