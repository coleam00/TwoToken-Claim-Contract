// SPDX-License-Identifier: MIT
 
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title Generic NFT smart contract for testing
 */
contract MockNFT is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIds;

    constructor() ERC721("GenericNFT", "GNRCNFT") {}

    function createToken() external onlyOwner returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        approve(address(this), newItemId);

        return newItemId;
    }    
}