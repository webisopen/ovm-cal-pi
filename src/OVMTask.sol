// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.13;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {OVMClient} from "@webisopen/ovm-contracts/src/OVMClient.sol";
import {
    Arch,
    ExecMode,
    GPUModel,
    Requirement,
    Specification
} from "@webisopen/ovm-contracts/src/libraries/DataTypes.sol";

abstract contract OVMTask is OVMClient, OwnableUpgradeable {
    bool public constant REQ_DETERMINISTIC = true;

    mapping(bytes32 requestId => string _response) internal _responseData;

    event ResponseParsed(bytes32 requestId, bool success, string response);

    function __OVMTask_init(address owner) public onlyInitializing {
        __Ownable_init(owner);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /**
     * @dev Sets the response data for a specific request.
     * @param requestId The ID of the request.
     * @param data The response data to be set.
     */
    function setResponse(bytes32 requestId, bytes calldata data)
        external
        virtual
        override
        recordResponse(requestId)
        onlyOVMGateway
    {
        (bool success, string memory response) = _parseData(data);
        if (success) {
            _responseData[requestId] = response;
        }

        emit ResponseParsed(requestId, success, response);
    }

    /**
     * @dev Retrieves the response associated with the given request ID.
     * @param requestId The ID of the request.
     * @return The response data as a string.
     */
    function getResponse(bytes32 requestId) external view virtual returns (string memory) {
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
     * @dev Internal function to parse response data. Must be implemented by child contracts.
     * @param data The input data to be parsed.
     * @return A tuple containing parsing results (implementation specific)
     */
    function _parseData(bytes calldata data) internal pure returns (bool, string memory) {
        return abi.decode(data, (bool, string));
    }
}
