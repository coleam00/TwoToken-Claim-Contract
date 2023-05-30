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

    // Contract for USDC - rewards are distributed in this currency
    IERC20 public USDC;

    // Max int for USDC approval.
    uint256 MAX_INT = 2**256 - 1;

    // Mapping to determine how much USDC each address can withdraw from OneNFT rewards.
    mapping(address => uint256) public addressToUSDCCanClaim;

    // Mapping to determine how much USDC each address has claimed.
    mapping(address => uint256) public addressToUSDCClaimed;

    event rewardsDeposited(uint256 indexed amount);
    event rewardsDepositedChunk(uint256 indexed amount, uint256 startIndex, uint256 endIndex);
    event rewardsClaimed(address indexed claimer, uint256 amount);

    constructor(address payable oneNFTAddress, address _USDC) {
        oneNFT = IERC721Enumerable(oneNFTAddress);
        USDC = IERC20(_USDC);
        USDC.approve(msg.sender, MAX_INT);
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
    * @dev Function to deposit rewards in USDC into the contract for OneNFT holders to claim.
    * @param amountUSDC the amount of USDC to deposit into the contract.
    */
    function depositRewards(uint256 amountUSDC) external payable {
        require(USDC.allowance(msg.sender, address(this)) >= amountUSDC, "You haven't approved this contract to spend enough UDSC to deposit as much as requsted.");
        
        uint256 totalNFTSupply = oneNFT.totalSupply();
        require(amountUSDC >= totalNFTSupply, "You must deposit enough USDC so it can be divided by the number of OneNFT holders.");
        require(totalNFTSupply > 0, "No OneNFTs have been minted yet.");

        USDC.transferFrom(msg.sender, address(this), amountUSDC);

        for (uint i = 1; i <= totalNFTSupply; i++) {
            address NFTOwner = oneNFT.ownerOf(i);
            addressToUSDCCanClaim[NFTOwner] = addressToUSDCCanClaim[NFTOwner] + (amountUSDC / totalNFTSupply);
        }

        emit rewardsDeposited(amountUSDC);
    }

    /**
    * @dev Function to deposit rewards in USDC in chunks into the contract for OneNFT holders to claim.
    * @param amountUSDC the amount of USDC to deposit for this chunk only.
    * @param startIndex the first index to deposit rewards for with this chunk.
    * @param endIndex the last index to deposit rewards for with this chunk.
    */
    function depositRewardsInChunks(uint256 amountUSDC, uint256 startIndex, uint256 endIndex) external payable {
        uint256 totalNFTSupply = oneNFT.totalSupply();
        if (endIndex > totalNFTSupply) {
            endIndex = totalNFTSupply;
        }
        require(endIndex > startIndex, "endIndex must be greater than startIndex");
        require(startIndex > 0, "startIndex must be greater than 0.");
        uint256 numNFTs = endIndex - startIndex + 1;

        require(USDC.allowance(msg.sender, address(this)) >= amountUSDC, "You haven't approved this contract to spend enough UDSC to deposit as much as requsted.");
        
        require(amountUSDC >= totalNFTSupply, "You must deposit enough USDC so it can be divided by the number of OneNFT holders.");
        require(totalNFTSupply > 0, "No OneNFTs have been minted yet.");

        USDC.transferFrom(msg.sender, address(this), amountUSDC);

        for (uint i = startIndex; i <= endIndex; i++) {
            address NFTOwner = oneNFT.ownerOf(i);
            addressToUSDCCanClaim[NFTOwner] = addressToUSDCCanClaim[NFTOwner] + (amountUSDC / numNFTs);
        }

        emit rewardsDepositedChunk(amountUSDC, startIndex, endIndex);
    }

    /**
    @dev Function for OneNFT holders to claim their rewards.
    */
    function claimRewards() external whenNotPaused {
        require(addressToUSDCCanClaim[msg.sender] > 0, "You don't have any rewards to claim! If you have a OneNFT, please wait until the next reward deposit.");
        
        uint256 claimAmount = addressToUSDCCanClaim[msg.sender];
        addressToUSDCCanClaim[msg.sender] = 0;
        USDC.transfer(msg.sender, claimAmount);

        emit rewardsClaimed(msg.sender, claimAmount);

        addressToUSDCClaimed[msg.sender] = addressToUSDCClaimed[msg.sender] + claimAmount;
    }

    /**
    * @dev updates the USDC contract.
    * @param newUSDCAddress the new USDC address
    */
    function updateUSDCAddress(address newUSDCAddress) external onlyOwner {
        USDC = IERC20(newUSDCAddress);
    }

    /**
    * @dev updates the OneNFT contract.
    * @param newOneNFTAddress the new OneNFT address
    */
    function updateOneNFTAddress(address newOneNFTAddress) external onlyOwner {
        oneNFT = IERC721Enumerable(newOneNFTAddress);
    }
}