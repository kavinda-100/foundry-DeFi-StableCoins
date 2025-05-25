// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {DecentralizeStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract DSCEngineTest is Test {
    DecentralizeStableCoin public dsc;
    DSCEngine public dscEngine;
    DeployDSC public deployer;
    HelperConfig public helperConfig;
    address ethUSDPriceFeed;
    address weth;

    address USER = makeAddr("user");

    uint256 public constant INITIAL_USER_ETH_BALANCE = 100 ether;
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, dscEngine, helperConfig) = deployer.run();
        ethUSDPriceFeed = helperConfig.getNetWorkConfig().wethUSDPriceFeed;
        weth = helperConfig.getNetWorkConfig().weth;

        vm.deal(USER, INITIAL_USER_ETH_BALANCE); // Give USER 1000 ether
        ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE); // Mint 10 WETH to USER
    }

    //? Price Feed Tests -----------------------------------------------

    function testGetUSDValue() external view {
        uint256 ethAmount = 15 ether;
        // 15e18 * 2000/ETH = 30000e18
        uint256 expectedUSDValue = 30000e18;
        uint256 actualUSDValue = dscEngine.getUSDValue(weth, ethAmount);
        assertEq(actualUSDValue, expectedUSDValue, "USD value should match expected value");
    }

    //? depositCollateral Tests -----------------------------------------------

    function testRevetIfCollateralIsZero() external {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dscEngine), AMOUNT_COLLATERAL);
        vm.expectRevert(DSCEngine.DSCEngine__MustBeMoreThanZero.selector);
        dscEngine.depositCollateral(weth, 0);
        vm.stopPrank();
    }
}
