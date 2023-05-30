// SPDX-License-Identifier: MIT
 
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Generic token smart contract for testing
 */
contract MockToken is ERC20, Ownable {
    constructor() ERC20("GenericToken", "GNRC") {
        _mint(msg.sender, 10 ** 40);
    }
}