##
## Init relayers wallets and paths
##

. ./.env

echo '[INFO] Sending 1Mi OSMO to relayer...'
osmosisd tx bank send $(osmosisd keys show $IBC_KEY -a --home $OSMOSISD_HOME --keyring-backend test) $(rly keys show $OSMOSIS_CHAIN_ID $RLY_KEY --home $RELAYER_HOME) 1000000000000uosmo --chain-id $OSMOSIS_CHAIN_ID --home $OSMOSISD_HOME --keyring-backend test --broadcast-mode block --node $OSMOSIS_RPC --yes

echo '[INFO] Sending 1Mi CYBER to relayer...'
cyber tx bank send $(cyber keys show $IBC_KEY -a --home $CYBER_HOME --keyring-backend test) $(rly keys show $CYBER_CHAIN_ID $RLY_KEY --home $RELAYER_HOME) 1000000000000boot --chain-id $CYBER_CHAIN_ID --home $CYBER_HOME --keyring-backend test --broadcast-mode block --node $CYBER_RPC --yes

echo '[INFO] Sending 1Mi XKI to relayer...'
kid tx bank send $(kid keys show $IBC_KEY -a --home $KID_HOME --keyring-backend test) $(rly keys show $KI_CHAIN_ID $RLY_KEY --home $RELAYER_HOME) 1000000000000uxki --chain-id $KI_CHAIN_ID --home $KID_HOME --keyring-backend test --broadcast-mode block --node $KI_RPC --yes

echo '[INFO] Sending 1Mi ATOM to relayer...'
gaiad tx bank send $(gaiad keys show $IBC_KEY -a --home $GAIAD_HOME --keyring-backend test) $(rly keys show $COSMOS_CHAIN_ID $RLY_KEY --home $RELAYER_HOME) 1000000000000uatom --chain-id $COSMOS_CHAIN_ID --home $GAIAD_HOME --keyring-backend test --broadcast-mode block --node $COSMOS_RPC --yes

echo '[INFO] Initializing Ki <> Osmosis relayer...'
rly paths generate $KI_CHAIN_ID $OSMOSIS_CHAIN_ID ki-osmosis --home $RELAYER_HOME
rly tx clients ki-osmosis --home $RELAYER_HOME
sleep 5
rly tx connection ki-osmosis --home $RELAYER_HOME
sleep 5
rly tx link ki-osmosis --home $RELAYER_HOME

echo '[INFO] Initializing Cosmos <> Osmosis relayer...'
rly paths generate $COSMOS_CHAIN_ID $OSMOSIS_CHAIN_ID cosmos-osmosis --home $RELAYER_HOME
rly tx clients cosmos-osmosis --home $RELAYER_HOME
sleep 5
rly tx connection cosmos-osmosis --home $RELAYER_HOME
sleep 5
rly tx link cosmos-osmosis --home $RELAYER_HOME

echo '[INFO] Initializing Cyber <> Osmosis relayer...'
rly paths generate $CYBER_CHAIN_ID $OSMOSIS_CHAIN_ID cyber-osmosis --home $RELAYER_HOME
rly tx clients cyber-osmosis --home $RELAYER_HOME
sleep 5
rly tx connection cyber-osmosis --home $RELAYER_HOME
sleep 5
rly tx link cyber-osmosis --home $RELAYER_HOME
