// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DecentralizeStableCoin} from "../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDSC is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns (DecentralizeStableCoin, DSCEngine) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getNetWorkConfig(); // Get the active network configuration
        // Set up the token addresses and price feed addresses
        tokenAddresses = [config.weth, config.wbtc];
        priceFeedAddresses = [config.wethUSDPriceFeed, config.wbtcUSDPriceFeed];

        vm.startBroadcast();
        // Deploy the Decentralized Stable Coin (DSC) and DSCEngine
        DecentralizeStableCoin dsc = new DecentralizeStableCoin();
        DSCEngine dscEngine = new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
        // transfer ownership of the DSC to the DSCEngine
        dsc.transferOwnership(address(dscEngine));

        vm.stopBroadcast();

        return (dsc, dscEngine);
    }
}
