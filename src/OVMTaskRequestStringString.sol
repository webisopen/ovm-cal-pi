// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.13;

import {OVMTask} from "./OVMTask.sol";

abstract contract OVMTaskRequestStringString is OVMTask {
    string internal constant REQUEST_ABIS =
        '[{"request":{"type":"function","name":"sendRequest","inputs":[{"name":"str1","type":"string","internalType":"string"},{"name":"str2","type":"string","internalType":"string"}],"outputs":[{"name":"requestId","type":"bytes32","internalType":"bytes32"}],"stateMutability":"payable"},"getResponse":{"type":"function","name":"getResponse","inputs":[{"name":"requestId","type":"bytes32","internalType":"bytes32"}],"outputs":[{"name":"","type":"string","internalType":"string"}],"stateMutability":"view"}}]';

    /**
     * @dev Sends a request to align two sequences.
     * @param str1 The first sequence to align(in url format).
     * @param str2 The second sequence to align(in url format).
     * @return requestId The ID of the request returned by the OVMGateway contract.
     */
    function sendRequest(string calldata str1, string calldata str2)
        external
        payable
        returns (bytes32 requestId)
    {
        // encode the two sequences
        bytes memory data = abi.encode(str1, str2);
        requestId = _sendRequest(msg.sender, msg.value, REQ_DETERMINISTIC, data);
    }
}
