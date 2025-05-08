// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

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
contract DSCEngine is ReentrancyGuard {
    // errors --------------------------------------------------------------------------------
    error DSCEngine__NeedMoreThanZero(); // amount must be more than zero
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength(); // token addresses and price feed addresses must be the same length
    error DSCEngine__NotAllowedToken(); // token is not allowed
    error DSCEngine__TransferFailed(); // transfer failed
    error DSCEngine__BrokenHealthFactor(uint256 healthFactor); // health factor is broken
    error DSCEngine__MintingFailed(); // minting failed

    // state variables --------------------------------------------------------------------
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10; // additional feed precision
    uint256 private constant PRECISION = 1e18; // additional feed precision
    uint256 private constant LIQUIDATION_THRESHOLD = 50; // liquidation threshold 200% overcollateralized
    uint256 private constant LIQUIDATION_PRECISION = 100; // liquidation threshold 200% overcollateralized
    uint256 private constant MIN_HEALTH_FACTOR = 1; // minimum health factor

    DecentralizedStableCoin private immutable i_dsc; // DSC token contract
    mapping(address _token => address _priceFeed) private s_priceFeeds; // token address => price feed address
    mapping(address _user => mapping(address _token => uint256 _amount)) private s_collateralDeposited; // user address => token address => amount of collateral
    mapping(address _user => uint256 _amount) private s_dscMinted; // user address => amount of DSC minted
    address[] private s_collateralTokens; // list of collateral tokens

    // events ------------------------------------------------------------------------------------
    event DepositCollateral(
        address indexed user, address indexed tokenCollateralAddress, uint256 indexed amountCollateral
    ); // event for deposit collateral

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
    constructor(address[] memory _tokenAddresses, address[] memory _priceFeedAddresses, address _DSCAddress) {
        // check if the token addresses and price feed addresses are the same length
        if (_tokenAddresses.length != _priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }

        // set the price feeds for each token address
        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            s_priceFeeds[_tokenAddresses[i]] = _priceFeedAddresses[i];
            s_collateralTokens.push(_tokenAddresses[i]);
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
    function depositCollateral(address _tokenCollateralAddress, uint256 _amountCollateral)
        external
        moreThanZero(_amountCollateral)
        isTokenAllowed(_tokenCollateralAddress)
        nonReentrant
    {
        // update the amount of collateral deposited by the user
        s_collateralDeposited[msg.sender][_tokenCollateralAddress] += _amountCollateral;

        // emit an event for the deposit
        emit DepositCollateral(msg.sender, _tokenCollateralAddress, _amountCollateral);

        // transfer the collateral from the user to this contract
        bool success = IERC20(_tokenCollateralAddress).transferFrom(msg.sender, address(this), _amountCollateral);
        // check if the transfer was successful and revert if it failed
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDSC() external {}

    function redeemCollateral() external {}

    /**
     * @param _amountDSCToMint The amount of DSC to mint.
     * @dev This function mints DSC tokens.
     */
    function mintDSC(uint256 _amountDSCToMint) external moreThanZero(_amountDSCToMint) nonReentrant {
        // update the amount of DSC minted by the user
        s_dscMinted[msg.sender] += _amountDSCToMint;

        _revertIfTheHealthFactorIsBroken(msg.sender);

        // mint the DSC tokens to the user
        bool success = i_dsc.mint(msg.sender, _amountDSCToMint);
        // check if the minting was successful and revert if it failed
        if (!success) {
            revert DSCEngine__MintingFailed();
        }
    }

    function burnDSC() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}

    // internal & private view functions --------------------------------------------------------------------
    function _revertIfTheHealthFactorIsBroken(address _user) internal view {
        // get the health factor of the user
        uint256 healthFactor = _getHealthFactor(_user);
        // check if the health factor is broken and revert if it is
        if (healthFactor < MIN_HEALTH_FACTOR) {
            revert DSCEngine__BrokenHealthFactor(healthFactor);
        }
    }

    /**
     * @dev This function calculates the health factor of a user.
     *      If user goes below 1, they are in danger of liquidation.
     * @param _user  The address of the user to check.
     * @return It return how close the user is to liquidation.
     */
    function _getHealthFactor(address _user) internal view returns (uint256) {
        // total dsc minted by the user
        // total collateral value
        (uint256 totalDSCMinted, uint256 collateralValueInUSD) = _getAccountInformation(_user);
        // get the health factor
        uint256 collateralAdjustedForThreshold = (collateralValueInUSD * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        /**
         * Example Scenario:
         * - User deposits 2 ETH as collateral, and the price of ETH is $2000.
         *   Total collateral value in USD = 2 * 2000 = $4000.
         * - The liquidation threshold is 50% (LIQUIDATION_THRESHOLD = 50).
         *   Adjusted collateral = (4000 * 50) / 100 = $2000.
         * - User mints 1500 DSC (totalDSCMinted = 1500).
         *
         * Health Factor Calculation:
         * - Health factor = (collateralAdjustedForThreshold * PRECISION) / totalDSCMinted.
         * - Health factor = (2000 * 1e18) / 1500 = 1.333e18 (1.333 scaled by 1e18).
         *
         * Interpretation:
         * - Since the health factor (1.333) is greater than 1, the user is safe from liquidation.
         * - If the user mints more DSC or the collateral value drops, the health factor may fall below 1,
         *   putting the user at risk of liquidation.
         */
        return (collateralAdjustedForThreshold * PRECISION) / totalDSCMinted; // health factor
    }

    /**
     * @dev This function gets the account information of a user.
     * @param _user  The address of the user to check.
     * @return It returns the total DSC minted and the total collateral value in USD.
     */
    function _getAccountInformation(address _user) internal view returns (uint256, uint256) {
        // get the total DSC minted by the user
        uint256 totalDSCMinted = s_dscMinted[_user];
        // get the total collateral value in USD
        uint256 collateralValueInUSD = getAccountCollateralValue(_user);
        return (totalDSCMinted, collateralValueInUSD);
    }

    // public & external view functions --------------------------------------------------------------------

    /**
     * @dev This function gets the collateral value of a user.
     * @param _user  The address of the user to check.
     * @return totalCollateralValueInUSD The total collateral value in USD.
     */
    function getAccountCollateralValue(address _user) public view returns (uint256 totalCollateralValueInUSD) {
        // get the total collateral value in USD
        // loop through the collateral deposited by the user
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            // get the token address
            address tokenAddress = s_collateralTokens[i];
            // get the amount of collateral deposited by the user
            uint256 amountCollateral = s_collateralDeposited[_user][tokenAddress];
            // get the price of the collateral in USD
            totalCollateralValueInUSD = getUSDValue(tokenAddress, amountCollateral);
        }

        return totalCollateralValueInUSD;
    }

    function getUSDValue(address _token, uint256 _amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[_token]);
        // get the latest price of the token in USD
        (, int256 price,,,) = priceFeed.latestRoundData();
        // get  price in USD
        uint256 totalValueInUSD = ((uint256(price) * ADDITIONAL_FEED_PRECISION) * _amount) / PRECISION; // assuming the price is in 18 decimals
        return totalValueInUSD;
    }
}
