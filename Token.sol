// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MintableToken is Ownable, ERC20 {
    constructor(
        address originalOwner
    ) Ownable(originalOwner) ERC20("Stare", "STR") {}

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
