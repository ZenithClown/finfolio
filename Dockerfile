# ==========================================
#   Copyright (c) 2020 Debmalya Pramanik   #
# ==========================================

# -------------------------------------------------------------------
#   Mnemonic:   Dockerfile
#   Abstract:   File for initializing application, and auto-scale
#               tailored email services using docker.
#
#   Date:       07 December 2021
#   Author:     Debmalya Pramanik
# -------------------------------------------------------------------

FROM tiangolo/uwsgi-nginx-flask:python3.8

# add maintainer tag
LABEL maintainer="Debmalya Pramanik <dpramanik.official@gmail.com>"

# add dummy app
ENV INSTALL_PATH /usr/src/mailer
RUN mkdir -p $INSTALL_PATH

# install net-tools mysql-client
# using mariadb-client inplace of mysql-client
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    net-tools \
  && apt-get install -y --no-install-recommends mariadb-client \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# set working directory
WORKDIR $INSTALL_PATH

# logging addition is included
# change the directory `app` as required
RUN mkdir -p /tmp/logs/mailer/

# setup flask environment
# install all requirements
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# copy all files and folder to docker
COPY . .

# run the application in docker environment
# you can use the wsgi service to start the application
CMD [ "python", "./manage.py" ]
