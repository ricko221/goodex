// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import './ERC20.sol';
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


contract Exchange is ERC20, ReentrancyGuard {

}

// Variables
address immutable tokenAddress; // The address of the ERC20 token (being traded)
address immutable factoryAddress; // The interface for the factory contract

// Events
event LiquidityAdded(address indexed provider, uint ethAmount, uint tokenAmount); // Emitted when liquidity is added
event LiquidityRemoved(address indexed provider, uint ethAmount, uint tokenAmount); // Emitted when liquidity is removed
event TokenPurchased(address indexed buyer, uint ethAmount, uint tokensReceived); // Emitted when a token (ERC-20) is purchased with ETH
event TokenSold(address indexed seller, uint tokensSold, uint ethReceived); // Emitted when ETH is purchased with a token

