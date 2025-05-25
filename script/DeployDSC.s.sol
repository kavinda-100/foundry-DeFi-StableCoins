// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DecentralizeStableCoin} from "../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";

contract DeployDSC is Script {
    function run() external returns (DecentralizeStableCoin, DSCEngine) {
        vm.startBroadcast();
        DecentralizeStableCoin dsc = new DecentralizeStableCoin();
        DSCEngine dscEngine = new DSCEngine();
        vm.stopBroadcast();

        return (dsc, dscEngine);
    }
}
