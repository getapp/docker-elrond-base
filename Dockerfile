FROM ruby:2.2.4

MAINTAINER Boris Mikhaylov

# replace sh with bash by default
RUN ln -snf /bin/bash /bin/sh

# add mongodb repository
RUN \
    apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10 && \
    echo "deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen" | tee /etc/apt/sources.list.d/mongodb.list

RUN apt-get update && \
    apt-get -y install git-core \
    curl \
    python-software-properties \
    software-properties-common \
    cron \
    libmysqlclient-dev \
    mongodb-org-tools \
    telnet \
    htop

# Install nvm with node and npm
RUN curl -sL https://deb.nodesource.com/setup | bash		
RUN apt-get -y install nodejs

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

WORKDIR /tmp

# install wait-for-it
RUN wget -q https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
 && mv wait-for-it.sh /usr/local/bin/wait-for-it \
 && chmod +x /usr/local/bin/wait-for-it

ENV REMOTE_CLI_VERSION 0.0.6
RUN wget https://github.com/kagux/go-remote-cli/releases/download/${REMOTE_CLI_VERSION}/linux-amd64-remote_cli.tar.bz2 \
    && tar -jxvf linux-amd64-remote_cli.tar.bz2 \
    && mv bin/linux/amd64/remote_cli /usr/local/bin/mahout


ENTRYPOINT ["/opt/entrypoint.sh"]

ONBUILD WORKDIR /app

ONBUILD ADD package.json /app/package.json
ONBUILD RUN npm set progress=false && npm install

ONBUILD ARG BUNDLE_WITHOUT='test development'
ONBUILD ADD Gemfile /app/Gemfile
ONBUILD ADD Gemfile.lock /app/Gemfile.lock
ONBUILD RUN bundle install --without $BUNDLE_WITHOUT

ONBUILD ADD . /app
