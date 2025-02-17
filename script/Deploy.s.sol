// SPDX-License-Identifier: MIT
// solhint-disable no-console,ordering,custom-errors
pragma solidity 0.8.24;

import {Pi} from "../src/tasks/Pi.sol";
import {SeqAligner} from "../src/tasks/SeqAligner.sol";
import {DeployConfig} from "./DeployConfig.s.sol";
import {Deployer} from "./Deployer.sol";
import {TransparentUpgradeableProxy} from
    "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {console} from "forge-std/console.sol";

contract Deploy is Deployer {
    DeployConfig internal _cfg;
    string[] private tasksToDeployArray;
    bool private useProxy;

    /// @notice Modifier that wraps a function in broadcasting.
    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    /// @notice The name of the script, used to ensure the right deploy artifacts
    ///         are used.
    function name() public pure override returns (string memory name_) {
        name_ = "Deploy";
    }

    function setUp() public override {
        super.setUp();
        string memory path =
            string.concat(vm.projectRoot(), "/deploy-config/", deploymentContext, ".json");
        _cfg = new DeployConfig(path);

        // Get tasks to deploy from environment variable, default to "Pi"
        string memory tasksArg = vm.envOr("DEPLOY_TASKS", string("Pi"));
        tasksToDeployArray = _split(tasksArg, ",");

        // Determine whether to use proxy from environment variable, default to true
        useProxy = vm.envOr("USE_PROXY", true);

        console.log("Deploying from %s", deployScript);
        console.log("Deployment context: %s", deploymentContext);
        console.log("Tasks to deploy: %s", tasksArg);
        console.log("Using proxy: %s", useProxy ? "true" : "false");
    }

    function run() external {
        deployImplementations();
        if (useProxy) {
            deployProxies();
            initializeTasks();
        }
    }

    /// @notice Deploy all of the proxies
    function deployProxies() public {
        for (uint256 i = 0; i < tasksToDeployArray.length; i++) {
            deployProxy(tasksToDeployArray[i]);
        }
    }

    function deployProxy(string memory name_) public broadcast returns (address addr_) {
        address logic = mustGetAddress(_stripSemver(name_));
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy({
            _logic: logic,
            initialOwner: _cfg.proxyAdminOwner(),
            _data: ""
        });

        string memory proxyName = string.concat(name_, "Proxy");
        save(proxyName, address(proxy));
        console.log("%s deployed at %s", proxyName, address(proxy));

        addr_ = address(proxy);
    }

    /// @notice Deploy all of the logic contracts
    function deployImplementations() public broadcast {
        for (uint256 i = 0; i < tasksToDeployArray.length; i++) {
            string memory taskName = tasksToDeployArray[i];
            console.log("Deploying %s.sol", taskName);

            address implementation = _deployImplementation(taskName);
            save(taskName, implementation);
            console.log("%s deployed at %s", taskName, implementation);
        }
    }

    function initializeTasks() public broadcast {
        for (uint256 i = 0; i < tasksToDeployArray.length; i++) {
            string memory taskName = string.concat(tasksToDeployArray[i], "Proxy");
            address proxyAddr = mustGetAddress(taskName);

            console.log("Initializing %s at %s", taskName, proxyAddr);
            if (_strEqual(tasksToDeployArray[i], "Pi")) {
                Pi(proxyAddr).initialize(_cfg.templateAdmin());
            } else if (_strEqual(tasksToDeployArray[i], "SeqAligner")) {
                SeqAligner(proxyAddr).initialize(_cfg.templateAdmin());
            }
        }
    }

    function _deployImplementation(string memory taskName) internal returns (address) {
        if (_strEqual(taskName, "Pi")) {
            Pi implementation = new Pi();
            return address(implementation);
        } else if (_strEqual(taskName, "SeqAligner")) {
            SeqAligner implementation = new SeqAligner();
            return address(implementation);
        }
        revert(string.concat("Unknown task: ", taskName));
    }

    function _split(string memory str, string memory delimiter)
        internal
        pure
        returns (string[] memory)
    {
        bytes memory strBytes = bytes(str);
        bytes memory delimiterBytes = bytes(delimiter);

        uint256 count = 1;
        for (uint256 i = 0; i < strBytes.length; i++) {
            if (strBytes[i] == delimiterBytes[0]) {
                count++;
            }
        }

        string[] memory parts = new string[](count);
        uint256 partIndex = 0;
        uint256 start = 0;

        for (uint256 i = 0; i < strBytes.length; i++) {
            if (strBytes[i] == delimiterBytes[0]) {
                parts[partIndex] = _substring(str, start, i);
                partIndex++;
                start = i + 1;
            }
        }
        parts[partIndex] = _substring(str, start, strBytes.length);

        return parts;
    }

    function _substring(string memory str, uint256 startIndex, uint256 endIndex)
        internal
        pure
        returns (string memory)
    {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function _strEqual(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
