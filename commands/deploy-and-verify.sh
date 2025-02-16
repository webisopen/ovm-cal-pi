#!/bin/bash
source .env

# Run deployment script and save output to temporary file
forge script script/Deploy.s.sol:Deploy \
--chain-id $CHAIN_ID \
--rpc-url $RPC_URL \
--private-key $PRIVATE_KEY \
--broadcast --ffi -vvvv | tee deploy_output.txt

# Extract contract addresses from output
while IFS= read -r line; do
    if [[ $line =~ Deploying[[:space:]]([^.]+)\.sol ]]; then
        CONTRACT_NAME="${BASH_REMATCH[1]}"
    elif [[ $line =~ deployed[[:space:]]at[[:space:]]([0-9a-fA-Fx]+) ]]; then
        CONTRACT_ADDRESS="${BASH_REMATCH[1]}"
        echo "Found contract: $CONTRACT_NAME at $CONTRACT_ADDRESS"
        
        # Execute verification
        echo "Verifying $CONTRACT_NAME..."
        forge verify-contract \
        --verifier-url $VERIFIER_URL \
        --verifier $VERIFIER \
        $CONTRACT_ADDRESS \
        "src/tasks/$CONTRACT_NAME.sol:$CONTRACT_NAME"
    fi
done < deploy_output.txt

# Clean up temporary file
rm deploy_output.txt 