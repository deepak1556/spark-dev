# VERSION:        0.1
# DESCRIPTION:    Create the spark editor in a container
# COMMENTS:
#   This file describes how to build the spark editor
#   in a container with all dependencies installed.
#   Tested on Debian Jessie.
# USAGE:
#   # Download atom Dockerfile
#   wget http://raw.githubusercontent.com/atom/atom/master/Dockerfile
#
#   # Build atom image
#   docker build -t spark .
#
#   docker run -v /tmp/.X11-unix:/tmp/.X11-unix \
#     -e DISPLAY=unix$DISPLAY spark
#

# Base docker image
FROM debian:jessie

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    git \
    libasound2 \
    libgconf-2-4 \
    libgnome-keyring-dev \
    libgtk2.0-0 \
    libnss3 \
    libxtst6 \
    --no-install-recommends

# install node
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs

# clone atom
RUN git clone https://github.com/deepak1556/spark-dev /src
WORKDIR /src
RUN git checkout nix_patch
RUN apt-get install -y wget
WORKDIR ./build/linux/
RUN bash build.sh

# Autorun atom
CMD /src/dist/linux/Spark\ Dev/bin/atom