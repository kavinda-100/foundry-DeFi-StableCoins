// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20, ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Decentralized Stable Coin (DSC)
 * @dev A decentralized stable coin contract that allows users to mint and redeem stable coins against collateral.
 * @author kavinda rathnayake
 * Collateral: Exogenous assets (e.g., ETH, BTC, etc.)
 * Minting: Algorithmic
 * Relative Stability: Pegged to a fiat currency (e.g., USD)
 */
contract DecentralizedStableCoin is ERC20Burnable, Ownable {
    // error messages
    error DecentralizedStableCoin__MustBeMoreThanZero();
    error DecentralizedStableCoin__NotEnoughBalanceToBurn();
    error DecentralizedStableCoin__NotTheZeroAddress();

    constructor() ERC20("DecentralizedStableCoin", "DSC") Ownable(msg.sender) {}

    function burn(uint256 _amount) public override onlyOwner {
        // get the user balance
        uint256 userBalance = balanceOf(msg.sender);
        // check if the user has enough balance to burn
        if (userBalance <= 0) {
            revert DecentralizedStableCoin__MustBeMoreThanZero();
        }
        if (userBalance < _amount) {
            revert DecentralizedStableCoin__NotEnoughBalanceToBurn();
        }
        // burn the amount
        super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) public onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert DecentralizedStableCoin__NotTheZeroAddress();
        }
        if (_amount <= 0) {
            revert DecentralizedStableCoin__MustBeMoreThanZero();
        }
        // mint the amount
        _mint(_to, _amount);
        return true;
    }
}
