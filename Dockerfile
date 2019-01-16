FROM ubuntu:16.04

ENV APP_ROOT=/opt/hello_world

RUN apt-get update && apt-get install -y \
  apt-utils \
  build-essential \
  language-pack-en \
  lsof \
  net-tools \
  python \
  python-pip \
  vim

ENV LANG=en_GB.UTF-8
ENV LANGUAGE=en_GB.UTF-8
ENV LC_ALL=en_GB.UTF-8

RUN pip install --upgrade pip
RUN pip install pipenv

RUN mkdir $APP_ROOT

WORKDIR $APP_ROOT

COPY . $APP_ROOT

RUN pipenv install --system

CMD pipenv run scripts/docker-start.sh
