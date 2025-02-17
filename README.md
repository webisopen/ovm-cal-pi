## OVM-Template-On-Chain

This is a demo repo using OVM contracts lib to implement different computation tasks onchain.

## Usage

The `main` branch is using `forge install` to manage the dependencies. If you prefer using `npm`, check the branch [`npm`](https://github.com/webisopen/ovm-cal-pi/tree/npm).

### Build

```shell
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
# Quick create new task
# It will create a new task contract under src/tasks/
node ./commands/create-task.js ./examples/task-specs/example-task.json

# With verification
# Update .env file with your own values. Specify the tasks to deploy in DEPLOY_TASKS.
./commands/deploy-and-verify.sh

# generate easily readable abi to /deployments
forge script script/Deploy.s.sol:Deploy --sig 'sync()' --rpc-url $RPC_URL --broadcast --ffi
```