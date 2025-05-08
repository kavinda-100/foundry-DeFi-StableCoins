// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";

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
    // errors --------------------------------------------------------------------------------
    error DSCEngine__NeedMoreThanZero(); // amount must be more than zero
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength(); // token addresses and price feed addresses must be the same length
    error DSCEngine__NotAllowedToken(); // token is not allowed

    // state variables --------------------------------------------------------------------
    DecentralizedStableCoin private immutable i_dsc; // DSC token contract
    mapping(address _token => address _priceFeed) private s_priceFeeds; // token address => price feed address

    // modifiers ------------------------------------------------------------------------------------
    /**
     * @dev Modifier to check if the amount is greater than zero.
     * @param _amount  The amount to check.
     */
    modifier moreThanZero(uint256 _amount) {
        if (_amount <= 0) {
            revert DSCEngine__NeedMoreThanZero();
        }
        _;
    }

    /**
     * @dev Modifier to check if the token is allowed.
     * @param _token  The address of the token to check.
     */
    modifier isTokenAllowed(address _token) {
        if (s_priceFeeds[_token] == address(0)) {
            revert DSCEngine__NotAllowedToken();
        }
        _;
    }

    // constructor ------------------------------------------------------------------------------------
    /**
     * @dev Constructor for the DSCEngine contract.
     * @param _tokenAddresses  The addresses of the tokens that can be used as collateral.
     * @param _priceFeedAddresses  The addresses of the price feeds for the tokens.
     * @param _DSCAddress  The address of the DSC token contract.
     */
    constructor(
        address[] memory _tokenAddresses,
        address[] memory _priceFeedAddresses,
        address _DSCAddress
    ) {
        // check if the token addresses and price feed addresses are the same length
        if (_tokenAddresses.length != _priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }

        // set the price feeds for each token address
        for (uint i = 0; i < _tokenAddresses.length; i++) {
            s_priceFeeds[_tokenAddresses[i]] = _priceFeedAddresses[i];
        }

        // set the DSC token address
        i_dsc = DecentralizedStableCoin(_DSCAddress);
    }

    // functions ------------------------------------------------------------------------------------

    function depositCollateralAndMintDSC() external {}

    /**
     * @dev This function deposits collateral into the system.
     * @param _tokenCollateralAddress  The address of the collateral token to deposit.
     * @param _amountCollateral  The amount of collateral to deposit.
     */
    function depositCollateral(
        address _tokenCollateralAddress,
        uint256 _amountCollateral
    ) external moreThanZero(_amountCollateral) {}

    function redeemCollateralForDSC() external {}

    function redeemCollateral() external {}

    function mintDSC() external {}

    function burnDSC() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}
