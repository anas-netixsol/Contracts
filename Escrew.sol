// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract Escrow is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public strToken;
    IUniswapV2Router02 public uniswapRouter;
    IUniswapV2Pair public lpToken;

    uint256 public adminFeePercent = 5; // Admin fee in percentage
    uint256 public strPrice; // Price of 1 STR token in Ether (wei)

    struct Transaction {
        address user;
        uint256 amount;
        bool isBuy;
    }

    Transaction[] public transactionHistory;

    event TokensAdded(uint256 amount);
    event FeeWithdrawn(uint256 amount);
    event TokensPurchased(
        address indexed user,
        uint256 amount,
        uint256 totalPrice
    );
    event TokensSold(address indexed user, uint256 amount, uint256 totalPrice);

    constructor(
        address _strToken,
        address _uniswapRouter,
        address initialOwner
    ) Ownable(initialOwner) {
        strToken = IERC20(_strToken);
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
    }

    // Set the price of 1 STR token in Ether (wei)
    function setStrPrice(uint256 _price) external onlyOwner {
        strPrice = _price;
    }

    // Add STR tokens to the escrow contract
    function addTokensToEscrow(uint256 _amount) external onlyOwner {
        strToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit TokensAdded(_amount);
    }

    // Withdraw admin fee from the contract
    function withdrawAdminFee() external onlyOwner {
        uint256 adminFee = (address(this).balance * adminFeePercent) / 100;
        payable(owner()).transfer(adminFee);
        emit FeeWithdrawn(adminFee);
    }

    // Buy STR tokens from the contract
    function buyTokens(uint256 _amount) external payable {
        uint256 totalPrice = (_amount * strPrice * (100 + adminFeePercent)) /
            100;
        require(msg.value >= totalPrice, "Insufficient Ether sent");

        strToken.safeTransfer(msg.sender, _amount); // Transfer STR tokens to the user
        payable(owner()).transfer(msg.value - totalPrice); // Transfer excess Ether to owner

        // Add the transaction to the history
        transactionHistory.push(Transaction(msg.sender, _amount, true));

        // Add liquidity to Uniswap
        address(this).balance;
    }
}
