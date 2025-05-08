// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title DSCEngine
 * @author Kavinda Rathnayake
 * @notice This contact is the core of the Decentralized Stable Coin (DSC) system.
 *         It manages the minting and redeeming DSC.
 *         It also handles deposits and withdrawals of collateral.
 * @notice The contract is VERY loosely based on the MakerDAO DSS (DAI) system.
 *
 * This system is designed to be as minimal as possible. and have the tokens maintain a 1 token == $1 peg.
 * This stablecoin has the properties:
 * - Exogenous collateral (ETH, BTC, etc.)
 * - Algorithmic stable
 * - Dollar-pegged
 *
 * It is similar to DAI if DAI had no governance, no fees, and was only backed by wETH nad wBTC.
 */
contract DSCEngine {
    function depositCollateralAndMintDSC() external {}

    function depositCollateral() external {}

    function redeemCollateralForDSC() external {}

    function redeemCollateral() external {}

    function mintDSC() external {}

    function burnDSC() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}
