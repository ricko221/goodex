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

// Liquidity Functions
function addLiquidity(uint tokensAdded) external payable nonReentrant returns (uint256) {
    require(msg.value > 0 && tokensAdded > 0, "Invalid values provided");

    uint ethBalance = address(this).balance;
    uint tokenBalance = getTokenReserves();

    if(tokenBalance == 0) {
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= tokensAdded, "Insufficient token balance");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), tokensAdded);
        uint liquidity = ethBalance;
        _mint(msg.sender, liquidity);
        emit LiquidityAdded(msg.sender, msg.value, tokensAdded);
        return liquidity;
    } else {
        uint liquidity = (msg.value * totalSupply()) / (ethBalance - msg.value);
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= tokensAdded, "Insufficient token balance");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), tokensAdded);
        _mint(msg.sender, liquidity);
        emit LiquidityAdded(msg.sender, msg.value, tokensAdded);
        return liquidity;
    }
}

function removeLiquidity(uint256 tokenAmount) external nonReentrant returns(uint, uint) {
    require(tokenAmount > 0, "Invalid token amount");

    uint ethAmount = (address(this).balance * tokenAmount) / totalSupply();
    uint tokenAmt = (getTokenReserves() * tokenAmount) / totalSupply();

    require((getTokenReserves() / address(this).balance) == ((getTokenReserves() + tokenAmt) / (address(this).balance + ethAmount)), "Invariant check failed");
    _burn(msg.sender, tokenAmount);

    payable(msg.sender).transfer(ethAmount);
    IERC20(tokenAddress).transfer
    (msg.sender, tokenAmt);

    emit LiquidityRemoved(msg.sender, ethAmount, tokenAmt);

    return (ethAmount, tokenAmt);
}
// Swap Functions
function swapEthForTokens(uint minTokens, address recipient) external payable nonReentrant returns (uint) {
    uint tokenAmount = getTokenAmount(msg.value);
    require(tokenAmount >= minTokens, "Token amount less than expected");

    IERC20(tokenAddress).transfer(recipient, tokenAmount);
    emit TokenPurchased(msg.sender, msg.value, tokenAmount);

    return tokenAmount;
}

function tokenForEthSwap(uint tokensSold, uint minEth) external nonReentrant returns(uint) {
    uint ethAmount = getEthAmount(tokensSold);
    require(ethAmount >= minEth, "ETH amount less than expected");

    IERC20(tokenAddress).transferFrom(msg.sender, address(this), tokensSold);
    payable(msg.sender).transfer(ethAmount);
    emit TokenSold(msg.sender, tokensSold, ethAmount);

    return ethAmount;
}
// Pricing Functions
function getTokenAmount(uint ethSold) public view returns (uint256) {
    require(ethSold > 0, "ETH sold must be greater than 0");
    uint outputReserve = getTokenReserves();
    return getAmount(ethSold, address(this).balance - ethSold, outputReserve);
}

function getEthAmount(uint tokensSold) public view returns (uint256) {
    require(tokensSold > 0, "Tokens sold must be greater than 0"); 
    uint inputReserve = getTokenReserves();
    return getAmount(tokensSold, inputReserve - tokensSold, address(this).balance);
}

function getAmount(uint inputAmount, uint inputReserve, uint outputReserve) public pure returns (uint256) {
    require(inputReserve > 0 && inputAmount > 0, "Invalid values provided");
    uint256 inputAmountWithFee = inputAmount * 997;
    uint256 numerator = inputAmountWithFee * outputReserve;
    uint256 denominator = (inputReserve * 1000) + inputAmountWithFee;
    return numerator / denominator;
}

// Contract Functions
function getTokenReserves() public view returns (uint256) {
    return IERC20(tokenAddress).balanceOf(address(this));
}
