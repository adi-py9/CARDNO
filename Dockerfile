# Cardano Toolchain Docker Image by 20BCE0456 ADITYA KRISHNA
# using ubuntu base image
FROM ubuntu:latest

LABEL maintainer="ADITYA KRISHNA <adityakrishna9525@gmail.com>"

# setting up working directory & installing sys dependencies
WORKDIR /app

# Installing os dependencies
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 curl libtool bash-completion autoconf -y

# Install ghcup and Haskell Stack
ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org -o get-ghcup.sh && \
    chmod +x get-ghcup.sh && \
    ./get-ghcup.sh && \
    rm get-ghcup.sh

ENV PATH=${PATH}:/root/.ghcup/bin


# Install cabal and GHC
RUN ghcup install cabal 3.10.1.0
RUN ghcup set cabal 3.10.1.0
RUN ghcup install ghc 9.6.2
RUN ghcup set ghc 9.6.2

# Update Path to include Cabal and GHC exports
ENV PATH=${PATH}:/root/.local/bin
ENV PATH=${PATH}:/root/.ghcup/bin
RUN echo "export PATH=/root/.local/bin:$PATH" >> $HOME/.bashrc
RUN echo "export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH" >> $HOME/.bashrc

# Reload .bashrc to apply environment changes
RUN /bin/bash -c "source $HOME/.bashrc"


# installing libsodium
RUN mkdir -p $HOME/cardano-src
WORKDIR /app/cardano-src
RUN git clone https://github.com/input-output-hk/libsodium
WORKDIR /app/cardano-src/libsodium
RUN git checkout dbb48cc
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

# cloned Cardano repo
WORKDIR /app/cardano-src
RUN git clone https://github.com/bitcoin-core/secp256k1
WORKDIR /app/cardano-src/secp256k1
RUN git checkout ac83be33
RUN ./autogen.sh
RUN ./configure --enable-module-schnorrsig --enable-experimental
RUN make
RUN make check
RUN make install

WORKDIR /app/cardano-src
RUN git clone https://github.com/input-output-hk/cardano-node.git
WORKDIR /app/cardano-src/cardano-node
RUN git fetch --all --recurse-submodules --tags

# checking out commit SHA 66f017f1
RUN git checkout master
RUN cabal update
RUN cabal configure --with-compiler=ghc-9.6.2
RUN cabal update
RUN cabal build all
RUN cabal clean
RUN cabal install --only-dependencies

RUN mkdir -p $HOME/.local/bin
RUN cp -p "$(./scripts/bin-path.sh cardano-node)" $HOME/.local/bin/
RUN cp -p "$(./scripts/bin-path.sh cardano-cli)" $HOME/.local/bin/

ENV PATH=${PATH}:$HOME/.local/bin

# Set entry point for running cardano-node by default
ENTRYPOINT ["cardano-node"]
