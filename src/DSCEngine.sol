// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DecentralizeStableCoin} from "./DecentralizedStableCoin.sol";

/**
 * @title DSCEngine
 * @author Kavinda Rathnayake
 * @dev This contract is the core engine of the Decentralized Stable Coin (DSC) system.
 * @notice This system is designed to be as minimal as possible. and have the tokens maintain a 1 token = 1 USD peg.
 * This Stable coin has the properties,
 * - Collateral: Exogenous (ETH, BTC)
 * - Minting: Algorithmic
 * - Relative Stability: Pegged to a fiat currency (e.g., USD)
 *
 * It is similar to MakerDAO's DAI system, id DAI had no governance and was fully algorithmic.
 *
 * @notice This contract is the core is the DSC System. It handle the all logic for minting and redeeming DSC,
 * as well as depositing and withdrawing collateral. This contract is VERY loosely based on the MakerDAO DSS (DAI) system.
 *
 * @notice IMPORTANT: This contract is always Over-Collateralize. This means that the value of the collateral must always be greater
 * than the value of the DSC minted.
 */
contract DSCEngine {
    // Errors -----------------------------------------------------
    error DSCEngine__MustBeMoreThanZero();
    error DSCEngine__PriceFeedAndTokenAddressLengthMismatch();
    error DSCEngine__TokenNotAllowed();

    // State Variables ----------------------------------------
    DecentralizeStableCoin private immutable i_DSCAddress; // the address of the DSC contract
    mapping(address token => address priceFeed) private s_priceFeeders; // token address => price feed address

    // contracts -------------------------------------------------
    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddress, address DSCAddress) {
        // check if the tokenAddresses and priceFeedAddress arrays are the same length
        if (tokenAddresses.length != priceFeedAddress.length) {
            revert DSCEngine__PriceFeedAndTokenAddressLengthMismatch();
        }
        // loop through the tokenAddresses and priceFeedAddress arrays and set the price feeders
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeders[tokenAddresses[i]] = priceFeedAddress[i];
        }
        // set the DSC address
        i_DSCAddress = DecentralizeStableCoin(DSCAddress);
    }

    // Modifiers ------------------------------------------------

    /**
     * @notice This modifier checks if the amount is greater than zero.
     * @param _amount The amount to check.
     */
    modifier moreThanZero(uint256 _amount) {
        if (_amount <= 0) {
            revert DSCEngine__MustBeMoreThanZero();
        }
        _;
    }

    /**
     * @notice This modifier checks if the collateral token is allowed.
     * @param _collateralToken The address of the collateral token.
     */
    modifier isAllowedCollateralToken(address _collateralToken) {
        if (s_priceFeeders[_collateralToken] == address(0)) {
            revert DSCEngine__TokenNotAllowed();
        }
        _;
    }

    // Functions -------------------------------------------------

    function depositCollateralAndMintDSC() external {}

    /**
     * @param _tokenCollateralAddress : The address of the collateral token.
     * @param _amountCollateral : The amount of collateral to deposit.
     */
    function depositCollateral(address _tokenCollateralAddress, uint256 _amountCollateral)
        external
        moreThanZero(_amountCollateral)
        isAllowedCollateralToken(_tokenCollateralAddress)
    {}

    function redeemCollateralForBurnDSC() external {}

    function redeemCollateral() external {}

    function mintDSC() external {}

    function burnDSC() external {}

    function liquidate() external {}

    function getHealthFactor() external view returns (uint256) {}
}
