// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.13;

import {OVMClient} from "@webisopen/ovm-contracts/src/OVMClient.sol";
import {
    Arch,
    ExecMode,
    GPUModel,
    Requirement,
    Specification
} from "@webisopen/ovm-contracts/src/libraries/DataTypes.sol";

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

event ResponseParsed(bytes32 requestId, bool success, string strPI);

contract Pi is OVMClient, OwnableUpgradeable {
    bool public constant REQ_DETERMINISTIC = true;

    mapping(bytes32 requestId => string _strPI) internal _responseData;

    function initialize(address admin) external initializer {
        __Ownable_init(admin);

        // set specification
        Specification memory spec;
        spec.name = "ovm-cal-pi";
        spec.version = "1.0.0";
        spec.description = "Calculate PI";
        spec.repository = "https://github.com/webisopen/ovm-pi";
        spec.repoTag = "9231c80a6cba45c8ff9a1d3ba19e8596407e8850";
        spec.license = "WTFPL";
        spec.requirement = Requirement({
            ram: "256mb",
            disk: "5mb",
            timeout: 600,
            cpu: 1,
            gpu: 0,
            gpuModel: GPUModel.T4
        });
        spec.apiABIs =
            '[{"request": {"type":"function","name":"sendRequest","inputs":[{"name":"numDigits","type":"uint256","internalType":"uint256"}],"outputs":[{"name":"requestId","type":"bytes32","internalType":"bytes32"}],"stateMutability":"payable"},"getResponse":{"type":"function","name":"getResponse","inputs":[{"name":"requestId","type":"bytes32","internalType":"bytes32"}],"outputs":[{"name":"","type":"string","internalType":"string"}],"stateMutability":"view"}}]';
        spec.royalty = 5;
        spec.execMode = ExecMode.JIT;
        spec.arch = Arch.AMD64;

        _updateSpecification(spec);
    }

    /**
     * @dev Sends a request to calculate the value of PI with a specified number of digits.
     * @param numDigits The number of digits to calculate for PI.
     * @return requestId The ID of the request returned by the OVMGateway contract.
     */
    function sendRequest(uint256 numDigits) external payable returns (bytes32 requestId) {
        // encode the data
        bytes memory data = abi.encode(numDigits);
        requestId = _sendRequest(msg.sender, msg.value, REQ_DETERMINISTIC, data);
    }

    /**
     * @dev Sets the response data for a specific request. This function is called by the OVMGateway
     * contract.
     * @param requestId The ID of the request.
     * @param data The response data to be set.
     */
    function setResponse(bytes32 requestId, bytes calldata data)
        external
        override
        recordResponse(requestId)
        onlyOVMGateway
    {
        // parse and save the data fulfilled by the OVMGateway contract
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
     * @dev Updates the specification of the OVM task.
     * @param spec The new specification to be set.
     */
    function updateSpecification(Specification memory spec) external onlyOwner {
        _updateSpecification(spec);
    }

    /**
     * @dev Updates the address of the OVMGateway contract.
     * @param OVMGatewayAddress The new address of the OVMGateway contract.
     */
    function updateOVMGateway(address OVMGatewayAddress) external onlyOwner {
        _updateOVMGatewayAddress(OVMGatewayAddress);
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
