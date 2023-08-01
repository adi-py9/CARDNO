#Cardano Toolchain Docker Image by 20BCE0456 ADITYA KRISHNA
# Using Amazon Linux base image
FROM amazonlinux:latest

LABEL maintainer="ADITYA KRISHNA <adityakrishna9525@gmail.com>"

#Setting up working directory & installing sys dependencies
WORKDIR /app 

RUN yum update -y && yum install -y \
    git \
    libtool \
    pkgconfig \
    openssl-devel \
    libffi-devel

#installation of Haskell compiler and Cabal 
RUN yum install -y ghc cabal-install

#clone the Cardano repository
RUN git clone https://github.com/input-output-hk/cardano-node.git

#install libsodium
RUN git clone https://github.com/input-output-hk/libsodium

#change current directory to the libsodium directory
WORKDIR /app/libsodium

#check out commit SHA 66f017f1
RUN git checkout 66f017f1

#building & installation of libsodium
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

#building and install Cardano node and CLI
WORKDIR /app/cardano-node

#updating Cabal to its latest version available
RUN cabal update

#installing cardano-node & cardano-cli using Cabal
RUN cabal install cardano-node cardano-cli

# Add Cardano binaries to the PATH
ENV PATH="/root/.cabal/bin:${PATH}"
