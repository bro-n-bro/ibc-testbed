##
## Initialize all networks
##

. ./.env

echo '[INFO] Testbed directory is '$IBC_TESDBED_HOME

sh scripts/stop-daemons.sh

echo '[INFO] Cleaning up testbed directories...'
rm -rf $CYBER_HOME
rm -rf $OSMOSISD_HOME
rm -rf $KID_HOME
rm -rf $GAIAD_HOME
rm -rf $RELAYER_HOME

echo '[INFO] Initializing networks keyring...'
osmosisd keys add $IBC_KEY --home $OSMOSISD_HOME --keyring-backend test
cyber keys add $IBC_KEY --home $CYBER_HOME --keyring-backend test
kid keys add $IBC_KEY --home $KID_HOME --keyring-backend test
gaiad keys add $IBC_KEY --home $GAIAD_HOME --keyring-backend test

echo '[INFO] Initializing Osmosis Network...'
cp ./genesis_config/osmosisd.json $OSMOSISD_HOME/config/genesis.json
osmosisd add-genesis-account $(osmosisd keys show $IBC_KEY -a --home $OSMOSISD_HOME --keyring-backend test) 1000000000000000uosmo --home $OSMOSISD_HOME
osmosisd gentx $IBC_KEY 1000000000000uosmo --chain-id=$OSMOSIS_CHAIN_ID --home $OSMOSISD_HOME --keyring-backend test
osmosisd collect-gentxs --home $OSMOSISD_HOME

echo '[INFO] Initializing Cyber Network...'
cp ./genesis_config/cyber.json $CYBER_HOME/config/genesis.json
cyber add-genesis-account $(cyber keys show $IBC_KEY -a --home $CYBER_HOME --keyring-backend test) 1000000000000000boot --home $CYBER_HOME
cyber gentx $IBC_KEY 1000000000000boot --chain-id=$CYBER_CHAIN_ID --home $CYBER_HOME --keyring-backend test
cyber collect-gentxs --home $CYBER_HOME

echo '[INFO] Initializing Ki Network...'
cp ./genesis_config/kid.json $KID_HOME/config/genesis.json
kid add-genesis-account $(kid keys show $IBC_KEY -a --home $KID_HOME --keyring-backend test) 1000000000000000uxki --home $KID_HOME
kid gentx $IBC_KEY 1000000000000uxki --chain-id=$KI_CHAIN_ID --home $KID_HOME --keyring-backend test
kid collect-gentxs --home $KID_HOME

echo '[INFO] Initializing Cosmos Network...'
cp ./genesis_config/gaiad.json $GAIAD_HOME/config/genesis.json
gaiad add-genesis-account $(gaiad keys show $IBC_KEY -a --home $GAIAD_HOME --keyring-backend test) 1000000000000000uatom --home $GAIAD_HOME
gaiad gentx $IBC_KEY 1000000000000uatom --chain-id=$COSMOS_CHAIN_ID --home $GAIAD_HOME --keyring-backend test
gaiad collect-gentxs --home $GAIAD_HOME

echo '[INFO] Initializing relayer confg and wallets...'
rly config init --home $RELAYER_HOME
cp ./relayer/$RELAYER_CONFIG_NAME $RELAYER_HOME/config/config.yaml
rly keys add $OSMOSIS_CHAIN_ID $RLY_KEY --home $RELAYER_HOME
rly keys add $CYBER_CHAIN_ID $RLY_KEY --home $RELAYER_HOME
rly keys add $KI_CHAIN_ID $RLY_KEY --home $RELAYER_HOME
rly keys add $COSMOS_CHAIN_ID $RLY_KEY --home $RELAYER_HOME
