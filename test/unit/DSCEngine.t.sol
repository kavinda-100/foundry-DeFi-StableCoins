// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {DecentralizeStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";

contract DSCEngineTest is Test {
    DecentralizeStableCoin public dsc;
    DSCEngine public dscEngine;
    DeployDSC public deployer;
    HelperConfig public helperConfig;

    address USER = makeAddr("user");

    uint256 public constant INITIAL_USER_ETH_BALANCE = 100 ether;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, dscEngine) = deployer.run();

        vm.deal(USER, INITIAL_USER_ETH_BALANCE); // Give USER 1000 ether
    }
}
