// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import  {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
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
contract DecentralizeStableCoin is ERC20Burnable, Ownable {

    // Errors -----------------------------------------------------
    error DecentralizeStableCoin__MustBeMoreThanZero();
    error DecentralizeStableCoin__BurnAmountExceedsBalance();

    constructor() ERC20("DecentralizeStableCoin", "DSC") {}

    function burn(uint256 _amount) public override onlyOwner {
        // get the balance of the user
        uint256 balance = balanceOf(msg.sender);
        // check if the user trying to burn zero tokens
        if( _amount <= 0) {
            revert DecentralizeStableCoin__MustBeMoreThanZero();
        }
        // check if the user has enough balance to burn
        if( balance < _amount) {
            revert DecentralizeStableCoin__BurnAmountExceedsBalance();
        }
        // Only the owner can burn tokens
        super.burn(_amount);
        
    }
    
}