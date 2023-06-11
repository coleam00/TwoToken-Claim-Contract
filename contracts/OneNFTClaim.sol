// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title OneNFT Claim Contract
 * @dev Claim contract for rewards distributed to the 500 OneNFT holders.
 */
contract OneNFTClaim is Pausable, Ownable {
    // References the deployed OneNFT contract.
    IERC721Enumerable public oneNFT;

    // Contract for TwoToken - rewards are distributed in this currency
    IERC20 public TwoToken;

    // Max int for TwoToken approval.
    uint256 MAX_INT = 2**256 - 1;

    // Mapping to determine how much TwoToken each address can withdraw from OneNFT rewards.
    mapping(address => uint256) public addressToTwoTokenCanClaim;

    // Mapping to determine how much TwoToken each address has claimed.
    mapping(address => uint256) public addressToTwoTokenClaimed;

    event rewardsDeposited(uint256 indexed amount);
    event rewardsDepositedChunk(uint256 indexed amount, uint256 startIndex, uint256 endIndex);
    event rewardsClaimed(address indexed claimer, uint256 amount);

    constructor(address payable oneNFTAddress, address _TwoToken) {
        oneNFT = IERC721Enumerable(oneNFTAddress);
        TwoToken = IERC20(_TwoToken);
        TwoToken.approve(msg.sender, MAX_INT);
    }

    /**
    @dev Only owner function to pause the reward claiming.
    */
    function pauseMinting() external onlyOwner {
        _pause();
    }

    /**
    @dev Only owner function to unpause the reward claiming.
    */
    function unpauseMinting() external onlyOwner {
        _unpause();
    }    

    /**
    * @dev Function to deposit rewards in TwoToken into the contract for OneNFT holders to claim.
    * @param amountTwoToken the amount of TwoToken to deposit into the contract.
    */
    function depositRewards(uint256 amountTwoToken) external payable {
        require(TwoToken.allowance(msg.sender, address(this)) >= amountTwoToken, "You haven't approved this contract to spend enough UDSC to deposit as much as requsted.");
        
        uint256 totalNFTSupply = oneNFT.totalSupply();
        require(amountTwoToken >= totalNFTSupply, "You must deposit enough TwoToken so it can be divided by the number of OneNFT holders.");
        require(totalNFTSupply > 0, "No OneNFTs have been minted yet.");

        TwoToken.transferFrom(msg.sender, address(this), amountTwoToken);

        for (uint i = 1; i <= totalNFTSupply; i++) {
            address NFTOwner = oneNFT.ownerOf(i);
            addressToTwoTokenCanClaim[NFTOwner] = addressToTwoTokenCanClaim[NFTOwner] + (amountTwoToken / totalNFTSupply);
        }

        emit rewardsDeposited(amountTwoToken);
    }

    /**
    * @dev Function to deposit rewards in TwoToken in chunks into the contract for OneNFT holders to claim.
    * @param amountTwoToken the amount of TwoToken to deposit for this chunk only.
    * @param startIndex the first index to deposit rewards for with this chunk.
    * @param endIndex the last index to deposit rewards for with this chunk.
    */
    function depositRewardsInChunks(uint256 amountTwoToken, uint256 startIndex, uint256 endIndex) external payable {
        uint256 totalNFTSupply = oneNFT.totalSupply();
        if (endIndex > totalNFTSupply) {
            endIndex = totalNFTSupply;
        }
        require(endIndex > startIndex, "endIndex must be greater than startIndex");
        require(startIndex > 0, "startIndex must be greater than 0.");
        uint256 numNFTs = endIndex - startIndex + 1;

        require(TwoToken.allowance(msg.sender, address(this)) >= amountTwoToken, "You haven't approved this contract to spend enough UDSC to deposit as much as requsted.");
        
        require(amountTwoToken >= totalNFTSupply, "You must deposit enough TwoToken so it can be divided by the number of OneNFT holders.");
        require(totalNFTSupply > 0, "No OneNFTs have been minted yet.");

        TwoToken.transferFrom(msg.sender, address(this), amountTwoToken);

        for (uint i = startIndex; i <= endIndex; i++) {
            address NFTOwner = oneNFT.ownerOf(i);
            addressToTwoTokenCanClaim[NFTOwner] = addressToTwoTokenCanClaim[NFTOwner] + (amountTwoToken / numNFTs);
        }

        emit rewardsDepositedChunk(amountTwoToken, startIndex, endIndex);
    }

    /**
    @dev Function for OneNFT holders to claim their rewards.
    */
    function claimRewards() external whenNotPaused {
        require(addressToTwoTokenCanClaim[msg.sender] > 0, "You don't have any rewards to claim! If you have a OneNFT, please wait until the next reward deposit.");
        
        uint256 claimAmount = addressToTwoTokenCanClaim[msg.sender];
        addressToTwoTokenCanClaim[msg.sender] = 0;
        TwoToken.transfer(msg.sender, claimAmount);

        emit rewardsClaimed(msg.sender, claimAmount);

        addressToTwoTokenClaimed[msg.sender] = addressToTwoTokenClaimed[msg.sender] + claimAmount;
    }

    /**
    * @dev updates the TwoToken contract.
    * @param newTwoTokenAddress the new TwoToken address
    */
    function updateTwoTokenAddress(address newTwoTokenAddress) external onlyOwner {
        TwoToken = IERC20(newTwoTokenAddress);
    }

    /**
    * @dev updates the OneNFT contract.
    * @param newOneNFTAddress the new OneNFT address
    */
    function updateOneNFTAddress(address newOneNFTAddress) external onlyOwner {
        oneNFT = IERC721Enumerable(newOneNFTAddress);
    }
}