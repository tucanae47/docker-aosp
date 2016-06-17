#
# Minimum Docker image to build Android AOSP
#
FROM ubuntu:12.04.5


MAINTAINER tedwang.tw@gmail.com

#
# fundamental packages
#
RUN apt-get update \
	&& apt-get install -y curl vim git man-db
# optional
RUN apt-get install -y sudo net-tools 

#
# AOSP requirement
#
# host toolchains
RUN apt-get install -y bison g++-multilib gperf libxml2-utils
RUN apt-get install -y gnupg flex build-essential \
	zip libc6-dev libncurses5-dev:i386 x11proto-core-dev \
	libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 \
	libgl1-mesa-dev mingw32 tofrodos \
	python-markdown xsltproc zlib1g-dev:i386

RUN apt-get install uuid uuid-dev
RUN sudo apt-get install zlib1g-dev liblz-dev
RUN sudo apt-get install liblzo2-2 liblzo2-dev
 

RUN ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so

# Clean up
RUN apt-get clean

#JAVA stuff
ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | /usr/bin/debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | /usr/bin/debconf-set-selections
RUN apt-get update
RUN apt-get install python-software-properties -y
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN apt-get install oracle-java6-installer -y
RUN apt-get install oracle-java6-set-default -y


# build becomes POSIX compliant
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
    dpkg-reconfigure -p critical dash

ADD https://commondatastorage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
RUN chmod 755 /usr/local/bin/*

# All builds will be done by user aosp
RUN useradd --create-home aosp && echo "aosp:aosp" | chpasswd && adduser aosp sudo
ADD gitconfig /home/aosp/.gitconfig
ADD ssh_config /home/aosp/.ssh/config
RUN chown aosp:aosp /home/aosp/.gitconfig

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/tmp/ccache", "/aosp"]

# Improve rebuild performance by enabling compiler cache
#ENV USE_CCACHE 1
ENV CCACHE_DIR /tmp/ccache

# Work in the build directory, repo is expected to be init'd here
USER aosp
WORKDIR /aosp

#Relogin to set env var such as USER
CMD sudo -i -u aosp



