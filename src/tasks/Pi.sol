// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.13;

import {OVMTaskRequestUint256} from "../OVMTaskRequestUint256.sol";
import {
    Arch,
    ExecMode,
    GPUModel,
    Requirement,
    Specification
} from "@webisopen/ovm-contracts/src/libraries/DataTypes.sol";

contract Pi is OVMTaskRequestUint256 {
    function initialize(address owner) public initializer {
        __OVMTask_init(owner);

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
        spec.apiABIs = REQUEST_ABIS;
        spec.royalty = 5;
        spec.execMode = ExecMode.JIT;
        spec.arch = Arch.AMD64;

        _updateSpecification(spec);
    }
}
