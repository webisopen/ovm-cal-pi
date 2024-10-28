// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {OVMClient} from "@webisopen/ovm-contracts/src/OVMClient.sol";
import {
    Arch,
    ExecMode,
    Requirement,
    Specification
} from "@webisopen/ovm-contracts/src/libraries/DataTypes.sol";

event ResponseParsed(bytes32 requestId, bool success, string strPI);

contract Pi is OVMClient {
    bool public constant REQ_DETERMINISTIC = true;

    mapping(bytes32 requestId => string _strPI) internal _responseData;

    /**
     * @dev Constructor function for the PI contract.
     * @param OVMTaskAddress The address of the OVMTask contract.
     * @param admin The address of the admin.
     */
    constructor(address OVMTaskAddress, address admin) OVMClient(OVMTaskAddress, admin) {
        // set specification
        Specification memory spec;
        spec.name = "kallypi";
        spec.version = "1.0.0";
        spec.description = "Calculate PI";
        spec.environment = "python:3.7";
        spec.repository = "https://github.com/kallydev/kallypi";
        spec.repoTag = "0xb6a6502fa480fd1fb5bf95c1fb1366bcbc335a08356c2a97daf6bc44e9cc0253";
        spec.license = "WTFPL";
        spec.entrypoint = "src/main.py";
        spec.requirement =
            Requirement({ram: "256mb", disk: "5mb", timeout: 600, cpu: 1, gpu: false});
        spec.apiABIs =
            '[{"request":{"type":"function","name":"getResponse","inputs":[{"name":"requestId","type":"bytes32","internalType":"bytes32"}],"outputs":[{"name":"","type":"string","internalType":"string"}],"stateMutability":"view"},"getResponse":{"type":"function","name":"getResponse","inputs":[{"name":"requestId","type":"bytes32","internalType":"bytes32"}],"outputs":[{"name":"","type":"string","internalType":"string"}],"stateMutability":"view"}}]';
        spec.royalty = 5;
        spec.execMode = ExecMode.JIT;
        spec.arch = Arch.ARM64;

        _updateSpecification(spec);
    }

    /**
     * @dev Sends a request to calculate the value of PI with a specified number of digits.
     * @param numDigits The number of digits to calculate for PI.
     * @return requestId The ID of the request returned by the OVMTasks contract.
     */
    function sendRequest(uint256 numDigits) external payable returns (bytes32 requestId) {
        // encode the data
        bytes memory data = abi.encode(numDigits);
        requestId = _sendRequest(msg.sender, msg.value, REQ_DETERMINISTIC, data);
    }

    /**
     * @dev Sets the response data for a specific request. This function is called by the OVMTasks
     * contract.
     * @param requestId The ID of the request.
     * @param data The response data to be set.
     */
    function setResponse(bytes32 requestId, bytes calldata data)
        external
        override
        recordResponse(requestId)
        onlyOVMTask
    {
        // parse and save the data fulfilled by the OVMTasks contract
        (bool success, string memory strPI) = _parseData(data);
        if (success) {
            _responseData[requestId] = strPI;
        }

        emit ResponseParsed(requestId, success, strPI);
    }

    /**
     * @dev Retrieves the response associated with the given request ID.
     * @param requestId The ID of the request.
     * @return The response data as a string in our pi calculation case.
     */
    function getResponse(bytes32 requestId) external view returns (string memory) {
        return _responseData[requestId];
    }

    /**
     * @dev Parses the given data and returns a boolean value and a string.
     * @param data The input data to be parsed.
     * @return A tuple containing a boolean value indicating the success of the task execution
     * and a string representing the parsed data.
     */
    function _parseData(bytes calldata data) internal pure returns (bool, string memory) {
        return abi.decode(data, (bool, string));
    }
}
