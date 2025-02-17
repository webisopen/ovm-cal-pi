pragma solidity 0.8.24;

import {Pi} from "../src/tasks/Pi.sol";
import {SeqAligner} from "../src/tasks/SeqAligner.sol";
import {Test} from "forge-std/Test.sol";

contract PiTest is Test {
    Pi public piTask;
    SeqAligner public seqAligner;
    address public constant OWNER = address(0x1111);
    address public constant MOCK_GATEWAY = address(0x1234);

    function setUp() public {
        piTask = new Pi();
        piTask.initialize(OWNER);

        vm.prank(OWNER);
        piTask.updateOVMGateway(MOCK_GATEWAY);

        seqAligner = new SeqAligner();
        seqAligner.initialize(OWNER);

        vm.prank(OWNER);
        seqAligner.updateOVMGateway(MOCK_GATEWAY);
    }

    // test specification set in initialize
    function testInitialSpecification() public view {
        assertEq(piTask.getSpecification().name, "ovm-cal-pi");
        assertEq(piTask.getSpecification().version, "1.0.0");
        assertEq(piTask.getSpecification().description, "Calculate PI");

        assertEq(seqAligner.getSpecification().name, "sequence-aligner");
        assertEq(seqAligner.getSpecification().version, "1.0.0");
        assertEq(seqAligner.getSpecification().description, "Sequence Aligner");
    }
}
