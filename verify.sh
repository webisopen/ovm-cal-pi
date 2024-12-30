export VERIFIER=blockscout
export VERIFIER_URL='https://scan.testnet.open.network/api'

forge verify-contract \
--verifier-url $VERIFIER_URL \
--verifier $VERIFIER \
0xTODO \
src/Pi.sol:Pi
