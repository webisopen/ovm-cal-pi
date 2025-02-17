#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Template for the task contract
const getContractTemplate = (name, baseContract, spec, params) => `// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {${baseContract}} from "../${baseContract}.sol";
import {
    Arch,
    ExecMode,
    GPUModel,
    Requirement,
    Specification
} from "@webisopen/ovm-contracts/src/libraries/DataTypes.sol";

contract ${name} is ${baseContract} {
    function initialize(address owner) public initializer {
        __OVMTask_init(owner);

        Specification memory spec;
        spec.name = "${spec.name}";
        spec.version = "${spec.version}";
        spec.description = "${spec.description}";
        spec.repository = "${spec.repository}";
        spec.repoTag = "${spec.repoTag}";
        spec.license = "${spec.license}";
        spec.requirement = Requirement({
            ram: "${spec.requirement.ram}",
            disk: "${spec.requirement.disk}",
            timeout: ${spec.requirement.timeout},
            cpu: ${spec.requirement.cpu},
            gpu: ${spec.requirement.gpu},
            gpuModel: GPUModel.${spec.requirement.gpuModel}
        });
        spec.apiABIs = REQUEST_ABIS;
        spec.royalty = ${spec.royalty};
        spec.execMode = ExecMode.${spec.execMode};
        spec.arch = Arch.${spec.arch};

        _updateSpecification(spec);
    }
}
`;

// Function to create a new task
function createTask(specPath) {
  // Read and parse the spec file
  const spec = JSON.parse(fs.readFileSync(specPath, 'utf8'));

  // Determine the base contract based on input/output types
  const inputTypes = spec.sendRequestInputType.trim();
  if (inputTypes !== 'Uint256' && inputTypes !== 'StringString') {
    throw new Error('Only Uint256 and StringString are supported for now');
  }
  const baseContract = `OVMTaskRequest${inputTypes}`;

  // Generate the contract code
  const contractCode = getContractTemplate(
    spec.contractName,
    baseContract,
    spec.specification
  );

  // Create the file
  const filePath = path.join(__dirname, '..', 'src', 'tasks', `${spec.contractName}.sol`);
  fs.writeFileSync(filePath, contractCode);

  console.log(`Created new task contract at: ${filePath}`);
}

// Check if spec file path is provided
if (process.argv.length < 3) {
  console.error('Please provide the path to the spec JSON file');
  process.exit(1);
}

createTask(process.argv[2]);