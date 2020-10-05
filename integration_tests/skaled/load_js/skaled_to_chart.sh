#!/bin/bash
ADDR=$1
shopt -s lastpipe

while true
do
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' $ADDR | jq '.result' | xargs printf '%d' | BN=$(</dev/stdin)
curl -X POST --data '{"jsonrpc":"2.0","method":"debug_interfaceCall","params":["SkaleHost trace count drop_good"],"id":2}' $ADDR | jq '.result' | xargs echo | T1=$(</dev/stdin)
curl -X POST --data '{"jsonrpc":"2.0","method":"debug_interfaceCall","params":["SkaleHost trace count import_consensus_born"],"id":3}' $ADDR | jq '.result' | xargs echo | T2=$(</dev/stdin)

TN=$(( $T1 + $T2 ))

echo $( date +%s ) $BN $TN >>skaled_chart.txt

sleep 1
done
