## Cal-Pi-On-Chain

This is a demo repo using OVM contracts lib to calculate Pi onchain.



## Usage

The `main` branch is using `forge install` to manage the dependencies. If you prefer using `npm`, check the branch [`npm`](https://github.com/webisopen/ovm-cal-pi/tree/npm).

### Build

```shell
$ npm install
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Deploy

```shell
# With verification
forge script script/Deploy.s.sol:Deploy \
--chain-id $CHAIN_ID \
--rpc-url $RPC_URL \
--private-key $PRIVATE_KEY \
--verifier-url $VERIFIER_URL \
--verifier $VERIFIER \
--verify \
--broadcast --ffi -vvvv

# Without verification
forge script script/Deploy.s.sol:Deploy \
--chain-id $CHAIN_ID \
--rpc-url $RPC_URL \
--private-key $PRIVATE_KEY \
--broadcast --ffi -vvvv


# generate easily readable abi to /deployments
forge script script/Deploy.s.sol:Deploy --sig 'sync()' --rpc-url $RPC_URL --broadcast --ffi
```