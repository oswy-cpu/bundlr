#!/bin/bash

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install curl wget jq libpq-dev libssl-dev \
build-essential pkg-config openssl ocl-icd-opencl-dev \
libopencl-clang-dev libgomp1 -y

. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/installers/docker.sh)

curl https://sh.rustup.rs -sSf | sh -s -- -y

source "$HOME/.cargo/env" && \
echo -e "\n$(cargo --version).\n"

curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash - && \
sudo apt-get install nodejs -y && \
echo -e "\nnodejs > $(node --version).\nnpm  >>> v$(npm --version).\n"

mkdir $HOME/bundlr; cd $HOME/bundlr

git clone \
--recurse-submodules https://github.com/Bundlr-Network/validator-rust.git

cd $HOME/bundlr/validator-rust && \
cargo run --bin wallet-tool create > wallet.json

cd $HOME/bundlr/validator-rust && \
cargo run --bin wallet-tool show-address \
--wallet wallet.json | jq ".address" | tr -d '"'

sleep 2

echo "========================================================================================================================"
echo "Токены по адресу нужно запросить тут - https://bundlr.network/faucet"
echo "========================================================================================================================"
                
cd $HOME/bundlr/validator-rust && \
docker-compose logs -f --tail 10

PORT=2109
echo "============================================================"
echo "Введите адрес кошелька"
echo "============================================================"
read ADDRESS
echo export PORT=${PORT} >> $HOME/.bash_profile
echo export ADDRESS=${ADDRESS} >> $HOME/.bash_profile
echo export BUNDLR_PORT=${PORT} >> $HOME/.bash_profile
source $HOME/.bash_profile

sudo tee <<EOF >/dev/null $HOME/bundlr/validator-rust/.env
PORT=${BUNDLR_PORT}
VALIDATOR_KEY=./wallet.json
BUNDLER_URL=https://testnet1.bundlr.network
GW_WALLET=./wallet.json
GW_CONTRACT=RkinCLBlY4L5GZFv8gCFcrygTyd5Xm91CzKlR6qxhKA
GW_ARWEAVE=https://arweave.testnet1.bundlr.network
EOF


cd $HOME/bundlr/validator-rust && \
docker-compose up -d

sleep 2

cd $HOME/bundlr/validator-rust && \
npm i -g @bundlr-network/testnet-cli

sleep 2

echo -e 'Проверить логи: \e[1m\e[32mcd $HOME/bundlr/validator-rust && \
docker-compose logs -f --tail 10'
echo -e 'Close logs Control+C and continiue install'

