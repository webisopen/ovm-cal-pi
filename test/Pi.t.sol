pragma solidity 0.8.24;

import {Pi} from "../src/tasks/Pi.sol";
import {SeqAligner} from "../src/tasks/SeqAligner.sol";
import {OVMTaskTest} from "./OVMTask.t.sol";

contract PiTest is OVMTaskTest {
    Pi public piTask;
    SeqAligner public seqAligner;

    function setUp() public override {
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
    function testInitialSpecification() public {
        assertEq(piTask.getSpecification().name, "ovm-cal-pi");
        assertEq(piTask.getSpecification().version, "1.0.0");
        assertEq(piTask.getSpecification().description, "Calculate PI");

        assertEq(seqAligner.getSpecification().name, "sequence-aligner");
        assertEq(seqAligner.getSpecification().version, "1.0.0");
        assertEq(seqAligner.getSpecification().description, "Sequence Aligner");
    }
}
