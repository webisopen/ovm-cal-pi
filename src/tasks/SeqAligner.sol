// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.13;

import {OVMTaskRequestStringString} from "../OVMTaskRequestStringString.sol";
import {
    Arch,
    ExecMode,
    GPUModel,
    Requirement,
    Specification
} from "@webisopen/ovm-contracts/src/libraries/DataTypes.sol";

contract SeqAligner is OVMTaskRequestStringString {
    function initialize(address owner) public initializer {
        __OVMTask_init(owner);

        Specification memory spec;
        spec.name = "sequence-aligner";
        spec.version = "1.0.0";
        spec.description = "Sequence Aligner";
        spec.repository = "https://github.com/webisopen/seq-aligner";
        spec.repoTag = "program/v0.1.0";
        spec.license = "WTFPL";
        spec.requirement = Requirement({
            ram: "256mb",
            disk: "5mb",
            timeout: 600,
            cpu: 1,
            gpu: 0,
            gpuModel: GPUModel.T4
        });
        spec.apiABIs = REQUEST_ABIS;
        spec.royalty = 5;
        spec.execMode = ExecMode.JIT;
        spec.arch = Arch.AMD64;

        _updateSpecification(spec);
    }
}
