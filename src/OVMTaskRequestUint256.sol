// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.13;

import {OVMTask} from "./OVMTask.sol";

abstract contract OVMTaskRequestUint256 is OVMTask {
    string internal constant REQUEST_ABIS =
        '[{"request": {"type":"function","name":"sendRequest","inputs":[{"name":"numDigits","type":"uint256","internalType":"uint256"}],"outputs":[{"name":"requestId","type":"bytes32","internalType":"bytes32"}],"stateMutability":"payable"},"getResponse":{"type":"function","name":"getResponse","inputs":[{"name":"requestId","type":"bytes32","internalType":"bytes32"}],"outputs":[{"name":"","type":"string","internalType":"string"}],"stateMutability":"view"}}]';

    /**
     * @dev Sends a request with a uint256 parameter.
     * @param value The uint256 value to be sent with the request.
     * @return requestId The ID of the request returned by the OVMGateway contract.
     */
    function sendRequest(uint256 value) external payable returns (bytes32 requestId) {
        bytes memory data = abi.encode(value);
        requestId = _sendRequest(msg.sender, msg.value, REQ_DETERMINISTIC, data);
    }
}
