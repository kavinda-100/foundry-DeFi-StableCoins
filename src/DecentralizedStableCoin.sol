// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import  {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
/**
 * @author Kavinda Rathnayake
 * @title Decentralized Stable Coin
 * @dev This contract represents a decentralized stable coin.
 * 
 * Collateral: Exogenous (ETH, BTC)
 * Minting: Algorithmic
 * Relative Stability: Pegged to a fiat currency (e.g., USD)
 * 
 * This contract meant to be governed by DSCEngine. This contract is just the ERC20 implementation of our stable coin system.
 */
contract DecentralizeStableCoin is ERC20Burnable {

    constructor() ERC20("DecentralizeStableCoin", "DSC") {}
    
}