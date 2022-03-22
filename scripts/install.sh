##
## Install base tools
##

echo '[INFO] Initializing environment...'
. ./.env

echo '[INFO] Installing build essentials...'
sudo apt-get install make build-essential --yes

echo '[INFO] Installing go v1.17.2...'
wget -q -O - https://git.io/vQhTU | bash -s -- --version 1.17.2

##
## Preparing tmp directory
##
mkdir ./tmp
cd ./tmp

##
## Install IBC enabled binaries
##

echo '[INFO] Installing Osmosis binary...'
git clone https://github.com/osmosis-labs/osmosis
cd osmosis
git checkout v7.0.4
make install
cd ..

echo '[INFO] Installing Cyber Network binary...'
git clone https://github.com/cybercongress/go-cyber.git cyber
cd cyber
git checkout v0.2.0
make install CUDA_ENABLED=false 
cd ..

echo '[INFO] Installing Ki binary...'
git clone https://github.com/KiFoundation/ki-tools.git
cd ki-tools
git checkout -b v2.0.1 tags/2.0.1
make install
cd ..

echo '[INFO] Installing Gaiad binarsh run.sh test-revive-relayy...'
git clone https://github.com/cosmos/gaia
cd gaia
git checkout v6.0.4
make install
cd ..

##
## Install go relayer
##

echo '[INFO] Installing Go Relayer...'
git clone https://github.com/lum-network/relayer.git
cd relayer
git checkout main
make install
cd ..

##
## Leaving tmp directory
##
cd ..

##
## Installing chain daemons
##

echo '[INFO] Installing networks daemons...'
sudo cp ./daemons/* /etc/systemd/system/.
sudo systemctl daemon-reload
sudo systemctl enable osmosisd
sudo systemctl enable cyber
sudo systemctl enable kid
sudo systemctl enable gaiad
