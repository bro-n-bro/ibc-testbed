##
## Test suite
## Will make the Cyber <> Cosmos IBC client expire and run a gov prop
## to revive this client
##

. ./.env

request_transfers() {
    ##
    ## Request IBC coin transfer from networks to Cosmos and from Cosmos to networks
    ##
    echo '[INFO] Transferring coins from Cyber to Cosmos...'
    if rly tx transfer $CYBER_CHAIN_ID $COSMOS_CHAIN_ID 1boot $(gaiad keys show $IBC_KEY -a --home $GAIAD_HOME --keyring-backend test) --path cyber-cosmos --home $RELAYER_HOME >/dev/null 2>&1; then
        echo "[INFO] Transaction accepted"
    else
        echo "[INFO] Transaction rejected"
    fi

    echo '[INFO] Transferring coins from Ki to Cosmos...'
    if rly tx transfer $KI_CHAIN_ID $COSMOS_CHAIN_ID 1uxki $(gaiad keys show $IBC_KEY -a --home $GAIAD_HOME --keyring-backend test) --path ki-cosmos --home $RELAYER_HOME >/dev/null 2>&1; then
        echo "[INFO] Transaction accepted"
    else
        echo "[INFO] Transaction rejected"
    fi

    echo '[INFO] Transferring coins from Osmosis to Cosmos ...'
    if rly tx transfer  $OSMOSIS_CHAIN_ID $COSMOS_CHAIN_ID 1uosmo $(gaiad keys show $IBC_KEY -a --home $GAIAD_HOME --keyring-backend test) --path cosmos-osmosis --home $RELAYER_HOME >/dev/null 2>&1; then
        echo "[INFO] Transaction accepted"
    else
        echo "[INFO] Transaction rejected"
    fi

    echo '[INFO] Transferring coins from Cosmos to Cyber...'
    if rly tx transfer $COSMOS_CHAIN_ID $CYBER_CHAIN_ID 1uatom $(cyber keys show $IBC_KEY -a --home $CYBER_HOME --keyring-backend test) --path cyber-cosmos --home $RELAYER_HOME >/dev/null 2>&1; then
        echo "[INFO] Transaction accepted"
    else
        echo "[INFO] Transaction rejected"
    fi

    echo '[INFO] Transferring coins from Cosmos to Ki...'
    if rly tx transfer $COSMOS_CHAIN_ID $KI_CHAIN_ID 1uatom $(kid keys show $IBC_KEY -a --home $KID_HOME --keyring-backend test) --path ki-cosmos --home $RELAYER_HOME >/dev/null 2>&1; then
        echo "[INFO] Transaction accepted"
    else
        echo "[INFO] Transaction rejected"
    fi

    echo '[INFO] Transferring coins from Cosmos to Osmosis...'
    if rly tx transfer $COSMOS_CHAIN_ID $OSMOSIS_CHAIN_ID 1uatom $(osmosisd keys show $IBC_KEY -a --home $OSMOSISD_HOME --keyring-backend test) --path cosmos-osmosis --home $RELAYER_HOME >/dev/null 2>&1; then
        echo "[INFO] Transaction accepted"
    else
        echo "[INFO] Transaction rejected"
    fi
}

# Trigger all transfers txs
request_transfers

# Relay all packets from all relays (should all work)
echo '[INFO] Relay packets manually (all realyers should work)...'
if rly tx relay-packets cyber-cosmos --home $RELAYER_HOME >/dev/null 2>&1 && rly tx relay-packets ki-cosmos --home $RELAYER_HOME >/dev/null 2>&1 && rly tx relay-packets cosmos-osmosis --home $RELAYER_HOME >/dev/null 2>&1; then
    echo "[INFO] Relaying done"
else
    echo "[ERROR] Relaying failed"
    exit 1
fi

# Relayer expiration must be high enough for the test to pass so we must wait
echo '[INFO] Waiting 5min for the Cyber <> Cosmos client to expire...'
sleep 300

# Trigger all transfers txs again
request_transfers

# Cyber <> Cosmos relayer should not be working anymore
echo '[INFO] Relay packets between Cyber <> Cosmos (should not work)...'
if rly tx raw update-client $COSMOS_CHAIN_ID $CYBER_CHAIN_ID 07-tendermint-2 --home $RELAYER_HOME ; then
    echo "[ERROR] Relaying is supposedly working but should not be"
    exit 1
else
    echo "[INFO] Relaying not working as expected"
fi

# Other relayers should work just fine and not be affected by the Cyber <> Cosmos relayer issue
echo '[INFO] Relay packets between other networks (should work)...'
if rly tx relay-packets ki-cosmos --home $RELAYER_HOME && rly tx relay-packets cosmos-osmosis --home $RELAYER_HOME ; then
    echo "[INFO] Relaying done"
else
    echo "[ERROR] Relaying failed"
    exit 1
fi

# Launching IBC fix for Cyber <> Cosmos relayer
echo '[INFO] Creating and updating new substitute client to replace the expired one...'
rly tx raw client $COSMOS_CHAIN_ID $CYBER_CHAIN_ID 07-tendermint-3 --home $RELAYER_HOME >/dev/null 2>&1
sleep 5
rly tx raw update-client $COSMOS_CHAIN_ID $CYBER_CHAIN_ID 07-tendermint-3 --home $RELAYER_HOME >/dev/null 2>&1

echo '[INFO] Running gov proposal on Cosmos to revive Cyber <> Cosmos relayer...'
gaiad tx gov submit-proposal update-client 07-tendermint-2 07-tendermint-3 --deposit 1000uatom --title "update" --description "upt clt" --from $IBC_KEY --home $GAIAD_HOME --keyring-backend test --broadcast-mode block --chain-id $COSMOS_CHAIN_ID --node $COSMOS_RPC --yes >/dev/null 2>&1
gaiad tx gov vote 1 yes --from $IBC_KEY --home $GAIAD_HOME --keyring-backend test --chain-id $COSMOS_CHAIN_ID --node $COSMOS_RPC --yes >/dev/null 2>&1

echo '[INFO] Waiting '$GOV_VOTE_DURATION's for the proposal to pass...'
sleep $GOV_VOTE_DURATION

echo '[INFO] Updating substitute client...'
rly tx raw update-client $COSMOS_CHAIN_ID $CYBER_CHAIN_ID 07-tendermint-3 --home $RELAYER_HOME >/dev/null 2>&1

# Trigger all transfers txs again
request_transfers

# Relay all packets from all relays (should all work)
echo '[INFO] Relay packets manually...'
if rly tx relay-packets cyber-cosmos --home $RELAYER_HOME  && rly tx relay-packets ki-cosmos --home $RELAYER_HOME && rly tx relay-packets cosmos-osmosis --home $RELAYER_HOME ; then
    echo "[INFO] Relaying done"
else
    echo "[ERROR] Relaying failed"
    exit 1
fi

# End test manual verification
# Each IBC transfer should have passed
# Even the ones done while Cyber <> Cosmos relayer was out of service since we revived the relayer
# Depending on some unpredictable behaviour the Cyber wallet might have only 2 (in case the tx was rejected which should be logged as well)
echo '[DEBUG] Dumping test wallets:\n - Cosmos wallet should have 3 ibc denom with 3 coins each\n - Each network should have an extra denom with 3 coins (uosmo IBC)'
sh scripts/dump-wallets.sh
