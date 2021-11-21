ALICE="./testnet/wallets/users/alice.pem"
PEM_FILE="./ping-pong.pem"
PING_PONG_CONTRACT="output/ping-pong.wasm"

PING_AMOUNT=1500000000000000000

PROXY_ARGUMENT="--proxy=https://devnet-api.elrond.com"
CHAIN_ARGUMENT="--chain=D"

build_ping_pong() {
    (set -x; erdpy --verbose contract build "$PING_PONG_CONTRACT")
}

deploy_ping_pong() {
    # local TOKEN_ID=0x45474c44 # "EGLD"
     # 1.5 EGLD
    local DURATION=86400 # 1 day in seconds
    # local ACTIVATION_TIMESTAMP= # skipped
    # local MAX_FUNDS= #skipped
    
    local OUTFILE="out.json"
    (set -x; erdpy contract deploy --bytecode="$PING_PONG_CONTRACT" \
        --pem="$ALICE" \
        $PROXY_ARGUMENT $CHAIN_ARGUMENT \
        --outfile="$OUTFILE" --recall-nonce --gas-limit=60000000 \
        --arguments ${PING_AMOUNT} ${DURATION} --send \
        || return)

    ADDRESS=$(erdpy data parse --file="$OUTFILE" --expression="data['emitted_tx']['address']")
    local RESULT_TRANSACTION=$(erdpy data parse --file="$OUTFILE" --expression="data['emitted_tx']['hash']")

    echo ""
    echo "Deployed contract with:"
    echo "  \$RESULT_ADDRESS == ${ADDRESS}"
    echo "  \$RESULT_TRANSACTION == ${RESULT_TRANSACTION}"
    echo ""
}

number_to_u64() {
    local NUMBER=$1
    printf "%016x" $NUMBER
}

sendPing(){
    (set -x; erdpy --verbose contract call ${ADDRESS} $PROXY_ARGUMENT $CHAIN_ARGUMENT --pem=${ALICE} --gas-limit=10000000 --recall-nonce --function="ping" --value=${PING_AMOUNT} --send)
}

getAcceptedToken(){
    (set -x; erdpy --verbose contract query ${ADDRESS} $PROXY_ARGUMENT --function="getAcceptedPaymentToken")
}

getPingAmount(){
    (set -x; erdpy --verbose contract query ${ADDRESS} $PROXY_ARGUMENT --function="getPingAmount")
}

getDurationTimestamp(){
    (set -x; erdpy --verbose contract query ${ADDRESS} $PROXY_ARGUMENT --function="getDurationTimestamp")
}

getUserPingTimestamp(){
    (set -x; erdpy --verbose contract query ${ADDRESS} $PROXY_ARGUMENT --function="getUserPingTimestamp")
}

didUserPing(){
    (set -x; erdpy --verbose contract query ${ADDRESS} $PROXY_ARGUMENT --function="didUserPing")
}

getAmount(){
    (set -x; erdpy --verbose contract query ${ADDRESS} $PROXY_ARGUMENT --function="getAmount")
}