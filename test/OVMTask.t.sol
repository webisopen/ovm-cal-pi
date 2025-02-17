// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {OVMTask} from "../src/OVMTask.sol";
import {Test} from "forge-std/Test.sol";

// Create a concrete implementation of OVMTask for testing
contract MockOVMTask is OVMTask {
    function initialize(address owner) public initializer {
        __OVMTask_init(owner);
    }
}

contract OVMTaskTest is Test {
    address public constant OWNER = address(0x1111);
    address public constant MOCK_GATEWAY = address(0x1234);

    MockOVMTask public task;

    event ResponseParsed(bytes32 requestId, bool success, string response);

    function setUp() public virtual {
        task = new MockOVMTask();
        task.initialize(OWNER);

        vm.prank(OWNER);
        task.updateOVMGateway(MOCK_GATEWAY);
        assertEq(task.owner(), OWNER);
    }

    function testSetResponse() public {
        bytes32 requestId = bytes32(uint256(1));
        bytes memory responseData = abi.encode(true, "test response");

        // Only Gateway can set response
        vm.expectRevert();
        task.setResponse(requestId, responseData);

        // Gateway should successfully set response
        vm.prank(MOCK_GATEWAY);
        vm.expectEmit();
        emit ResponseParsed(requestId, true, "test response");
        task.setResponse(requestId, responseData);

        assertEq(task.getResponse(requestId), "test response");
    }

    function testWithdraw() public {
        // Transfer some ETH to the contract
        vm.deal(address(task), 1 ether);

        // Non-owner cannot withdraw
        vm.prank(address(0x9999));
        vm.expectRevert();
        task.withdraw();

        // Owner can withdraw
        uint256 ownerBalanceBefore = OWNER.balance;
        vm.prank(OWNER);
        task.withdraw();

        assertEq(address(task).balance, 0);
        assertEq(OWNER.balance, ownerBalanceBefore + 1 ether);
    }

    function testUpdateOVMGateway() public {
        address newGateway = address(0x5678);

        // Non-owner cannot update gateway
        vm.prank(address(0x9999));
        vm.expectRevert();
        task.updateOVMGateway(newGateway);

        // Owner can update gateway
        vm.prank(OWNER);
        task.updateOVMGateway(newGateway);
    }

    function testDoubleInitializationReverts() public {
        vm.expectRevert();
        task.initialize(OWNER);
    }

    function testOnlyGatewayCanSetResponse() public {
        bytes32 requestId = bytes32(uint256(1));
        bytes memory responseData = abi.encode(true, "test response");

        // Non-gateway address cannot set response
        vm.prank(address(0x9999));
        vm.expectRevert();
        task.setResponse(requestId, responseData);

        // Gateway can set response
        vm.prank(MOCK_GATEWAY);
        task.setResponse(requestId, responseData);
    }

    receive() external payable {}
}
