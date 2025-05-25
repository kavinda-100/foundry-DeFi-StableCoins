// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DecentralizeStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

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
contract DSCEngine is ReentrancyGuard {
    //? Errors -----------------------------------------------------

    error DSCEngine__MustBeMoreThanZero();
    error DSCEngine__PriceFeedAndTokenAddressLengthMismatch();
    error DSCEngine__TokenNotAllowed();
    error DSCEngine__TransferFailed();
    error DSCEngine__HealthFactorBroken(uint256 healthFactor, uint256 minHealthFactor);
    error DSCEngine__MintDSCFailed();

    //? State Variables ----------------------------------------
    //* Constants
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10; // 10^10, used to adjust the price feed values to match the precision of the DSC token
    uint256 private constant PRECISION = 1e18; // 10^18, used to adjust the values to match the precision of the DSC token
    uint256 private constant LIQUIDATION_THRESHOLD = 50; // 50%, the threshold at which a user can be liquidated
    uint256 private constant LIQUIDATION_PRECISION = 100; // 100%, used to adjust the values to match the precision of the DSC token
    uint256 private constant MIN_HEALTH_FACTOR = 1e18; // 1.0, the minimum health factor a user must have to avoid liquidation
    //* other state variables
    DecentralizeStableCoin private immutable i_DSCAddress; // the address of the DSC contract
    mapping(address token => address priceFeed) private s_priceFeeders; // token address => price feed address
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited; // user address => token address => amount of collateral deposited
    mapping(address user => uint256 amountDSCMinted) private s_DSCMinted; // user address => amount of DSC minted
    address[] private s_CollateralTokens; // array of allowed collateral tokens

    //? Events -----------------------------------------------------
    event CollateralDeposited(address indexed user, address indexed token, uint256 amount);

    //? contracts -------------------------------------------------

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddress, address DSCAddress) {
        // check if the tokenAddresses and priceFeedAddress arrays are the same length
        if (tokenAddresses.length != priceFeedAddress.length) {
            revert DSCEngine__PriceFeedAndTokenAddressLengthMismatch();
        }
        // loop through the tokenAddresses and priceFeedAddress arrays and set the price feeders
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeders[tokenAddresses[i]] = priceFeedAddress[i];
            s_CollateralTokens.push(tokenAddresses[i]); // add the token to the collateral tokens array
        }
        // set the DSC address
        i_DSCAddress = DecentralizeStableCoin(DSCAddress);
    }

    //? Modifiers ------------------------------------------------

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

    //? Functions (external & public)-------------------------------------------------

    function depositCollateralAndMintDSC() external {}

    /**
     * @param _tokenCollateralAddress : The address of the collateral token.
     * @param _amountCollateral : The amount of collateral to deposit.
     */
    function depositCollateral(address _tokenCollateralAddress, uint256 _amountCollateral)
        external
        moreThanZero(_amountCollateral)
        isAllowedCollateralToken(_tokenCollateralAddress)
        nonReentrant
    {
        // update the amount of collateral deposited
        s_collateralDeposited[msg.sender][_tokenCollateralAddress] += _amountCollateral;
        // emit the CollateralDeposited event
        emit CollateralDeposited(msg.sender, _tokenCollateralAddress, _amountCollateral);
        // transfer the collateral from the user to this contract
        bool success = IERC20(_tokenCollateralAddress).transferFrom(msg.sender, address(this), _amountCollateral);
        // check if the transfer was successful
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForBurnDSC() external {}

    function redeemCollateral() external {}

    /**
     * @notice This function mints DSC tokens.
     * @param _amountDSCToMint The amount of DSC tokens to mint.
     * @notice They must have more collateral than the minimum threshold.
     * @dev This function is non-reentrant and checks that the amount to mint is greater than zero.
     */
    function mintDSC(uint256 _amountDSCToMint) external moreThanZero(_amountDSCToMint) nonReentrant {
        // update the amount of DSC minted
        s_DSCMinted[msg.sender] += _amountDSCToMint;
        // check if the user has enough collateral to mint the DSC
        _revertIfHeathFactorIsBroken(msg.sender);
        // mint the DSC tokens to the user
        bool success = i_DSCAddress.mint(msg.sender, _amountDSCToMint);
        // check if the minting was successful
        if (!success) {
            revert DSCEngine__MintDSCFailed();
        }
    }

    function burnDSC() external {}

    function liquidate() external {}

    function getHealthFactor() external view returns (uint256) {}

    /**
     * @notice This function returns the total amount of collateral deposited by the user in USD.
     * @param _user The address of the user to get the collateral value for.
     * @return totalCollateralValueInUSD The total value of the collateral deposited by the user in USD.
     */
    function getAccountCollateralValueInUSD(address _user) public view returns (uint256 totalCollateralValueInUSD) {
        // loop through all collateral tokens deposited by the user, get the amount they have deposited, and
        // map to the price feed to get the price of the token in USD
        for (uint256 i = 0; i < s_CollateralTokens.length; i++) {
            address collateralToken = s_CollateralTokens[i];
            uint256 amountCollateral = s_collateralDeposited[_user][collateralToken];
            totalCollateralValueInUSD += getUSDValue(collateralToken, amountCollateral);
        }
        return totalCollateralValueInUSD;
    }

    /**
     * @notice This function returns the USD value of a given token amount.
     * @param _token The address of the token to get the USD value for.
     * @param _amount The amount of the token to get the USD value for.
     * @return The USD value of the given token amount.
     */
    function getUSDValue(address _token, uint256 _amount) public view returns (uint256) {
        // 1. Get the price feed address for the token
        // 2. Get the price of the token in USD
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeders[_token]);
        (, int256 price,,,) = priceFeed.latestRoundData();
        // 1 ETH = 1000 USD
        // The returned value from Chainlink will be 1000 * 1e8
        // Most USD pairs have 8 decimals, so we will just pretend they all do
        // We want to have everything in terms of WEI, so we add 10 zeros at the end
        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * _amount) / PRECISION;
    }

    //? Functions (internal & private)-------------------------------------------------

    /**
     * @notice This function gets the total DSC minted and the total collateral value in USD for a user.
     * @param _user The address of the user to get the information for.
     * @return totalDSCMinted The total DSC minted by the user.
     * @return totalCollateralValueInUSD The total collateral value in USD deposited by the user.
     */
    function _getAccountInformation(address _user)
        private
        view
        returns (uint256 totalDSCMinted, uint256 totalCollateralValueInUSD)
    {
        // 1. Get the total DSC minted by the user
        // 2. Get the total collateral value in usd deposited by the user
        // 3. Return both values
        totalDSCMinted = s_DSCMinted[_user];
        totalCollateralValueInUSD = getAccountCollateralValueInUSD(_user);
        return (totalDSCMinted, totalCollateralValueInUSD);
    }

    /**
     * @notice This function calculates the health factor of a user by checking how close they are to liquidation.
     * @param _user The address of the user to calculate the health factor for.
     * @return The health factor of the user.
     * @dev If the user goes below 1, they are at risk of liquidation.
     */
    function _heathFactor(address _user) private view returns (uint256) {
        // 1. Get the total DSC minted by the user
        // 2. Get the total collateral value deposited by the user
        (uint256 totalDSCMinted, uint256 totalCollateralValueInUSD) = _getAccountInformation(_user);
        uint256 CollateralAdjustedThreshold =
            (totalCollateralValueInUSD * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;

        // ! Example 1:
        // (1000 ETH * LIQUIDATION_THRESHOLD (50)) => (50,000 => 50,000 / LIQUIDATION_PRECISION) => 500
        // 150 ETH / 100 DSC = 1.5
        // (150 * 50) => (7500 / 100) => (75 / 1000) => 0.075 < 1 => user is at risk of liquidation

        // ! Example 2:
        // Assume user has $2,000 worth of collateral and has minted 1,000 DSC.
        // LIQUIDATION_THRESHOLD = 50 (50%), LIQUIDATION_PRECISION = 100, PRECISION = 1e18
        // CollateralAdjustedThreshold = (2,000 * 50) / 100 = $1,000
        // Health factor = ($1,000 * 1e18) / 1,000 = 1e18 (which is 1.0 in 18 decimals)
        // If health factor < 1e18 (i.e., < 1.0), user is at risk of liquidation.

        return (CollateralAdjustedThreshold * PRECISION) / totalDSCMinted;
    }

    /**
     * @notice This function checks if the user's health factor is broken and reverts if it is.
     * @param _user The address of the user to check the health factor for.
     * @dev This function is used to ensure that the user has enough collateral to cover the DSC minted.
     */
    function _revertIfHeathFactorIsBroken(address _user) internal view {
        // 1. Check health factor (do they have enough collateral to cover the DSC minted?)
        // 2. Revert if the health factor is broken
        uint256 healthFactor = _heathFactor(_user);
        if (healthFactor < MIN_HEALTH_FACTOR) {
            revert DSCEngine__HealthFactorBroken(healthFactor, MIN_HEALTH_FACTOR);
        }
    }
}
