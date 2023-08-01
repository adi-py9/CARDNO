#Cardano Toolchain Docker Image by 20BCE0456 ADITYA KRISHNA
#using ubuntu base image
FROM ubuntu:latest

LABEL maintainer="ADITYA KRISHNA <adityakrishna9525@gmail.com>"

#setting up working directory & installing sys dependencies
WORKDIR /app 

RUN apt-get update && apt-get install -y \
    git \
    libtool \
    pkg-config \
    libssl-dev \
    libffi-dev \
    automake \
    build-essential \
    curl

#installing Haskell compiler | cabal is pre - installed 
RUN apt-get install -y haskell-platform

#cloned Cardano repo
RUN git clone https://github.com/input-output-hk/cardano-node.git

#installing libsodium
RUN git clone https://github.com/input-output-hk/libsodium

#changing current directory to the libsodium directory
WORKDIR /app/libsodium

#checking out commit SHA 66f017f1
RUN git checkout 66f017f1

#building & installation of libsodium
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

#changing the directory 
WORKDIR /app/cardano-node

#updating Cabal to its latest version available
RUN cabal update

#installing cardano-node & cardano-cli using Cabal
RUN cabal install cardano-node cardano-cli

#adding Cardano binaries to the PATH
ENV PATH="/root/.cabal/bin:${PATH}"
