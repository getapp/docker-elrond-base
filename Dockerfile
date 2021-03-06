FROM ruby:2.3

MAINTAINER Boris Mikhaylov

# replace sh with bash by default
RUN ln -snf /bin/bash /bin/sh

# install mongodump
ENV MONGO_VERSION 3.2.4
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 \
 && echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list

# install libssl1.0.0
RUN wget http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u11_amd64.deb && \
    dpkg -i libssl1.0.0_1.0.1t-1+deb8u11_amd64.deb

RUN apt-get update && \
    apt-get -y install git-core \
    curl \
    software-properties-common \
    cron \
    default-libmysqlclient-dev \
    mongodb-org-tools=$MONGO_VERSION \
    telnet \
    htop

# Install nvm with node and npm
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash
RUN apt-get -y install nodejs

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

WORKDIR /tmp

# install wait-for-it
RUN wget -q https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
 && mv wait-for-it.sh /usr/local/bin/wait-for-it \
 && chmod +x /usr/local/bin/wait-for-it

ENV REMOTE_CLI_VERSION 0.0.8
RUN wget https://github.com/kagux/go-remote-cli/releases/download/${REMOTE_CLI_VERSION}/linux-amd64-remote_cli.tar.bz2 \
    && tar -jxvf linux-amd64-remote_cli.tar.bz2 \
    && mv bin/linux/amd64/remote_cli /usr/local/bin/mahout

# https://github.com/bundler/bundler/issues/4576
RUN gem update --system 2.6.1 && gem install bundler

ENTRYPOINT ["/opt/entrypoint.sh"]

WORKDIR /app
