pragma solidity 0.8.24;

import {Pi, ResponseParsed} from "../src/Pi.sol";
import {Test} from "forge-std/Test.sol";

contract PiTest is Test {
    address public constant alice = address(0x1111);
    address public constant mockTask = address(0x1234abcd);
    Pi public pi;

    function setUp() public {
        pi = new Pi();

        pi.initialize(alice);

        vm.prank(alice);
        pi.updateOVMGateway(address(mockTask));
    }

    function testSetResponse() public {
        bytes memory mockData = abi.encode(true, "3.14159");
        vm.prank(mockTask);
        vm.expectEmit();
        emit ResponseParsed("0x1234", true, "3.14159");
        pi.setResponse("0x1234", mockData);

        string memory strPI = pi.getResponse("0x1234");
        vm.assertEq(strPI, "3.14159");
    }

    function testWithdraw() public {
        // Fund the contract
        vm.deal(address(pi), 1 ether);

        // Ensure only owner can withdraw
        vm.expectRevert();
        pi.withdraw();

        // Check withdrawal by owner
        uint256 aliceBalanceBefore = alice.balance;
        vm.prank(alice);
        pi.withdraw();

        assertEq(address(pi).balance, 0);
        assertEq(alice.balance, aliceBalanceBefore + 1 ether);
    }
}
