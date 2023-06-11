from scripts.helpers import get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS
from scripts.deploy_mock_nft import deploy_mock_nft
from scripts.deploy_mock_token import deploy_mock_token
from scripts.deploy_claim_contract import deploy_claim_contract
from brownie import network, accounts, exceptions
from web3 import Web3
import pytest

def test_owner_can_deposit_TwoToken():
    # Arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("This test is only for local blockchains.")

    account = get_account()
    account2 = get_account(2)
    account3 = get_account(3)
    mockTwoToken = deploy_mock_token()
    mockNFT = deploy_mock_nft()
    claimContract = deploy_claim_contract(mockNFT.address, mockTwoToken.address)

    # Act
    account2NFTCount = 15
    account3NFTCount = 5
    depositAmount = 1000

    for i in range(account2NFTCount):
        currTokenId = mockNFT.createToken.call({"from": account})
        currTokenIdTx = mockNFT.createToken({"from": account})
        currTokenIdTx.wait(1)
        mockNFT.safeTransferFrom(account.address, account2.address, currTokenId, {"from": account})

    for i in range(account3NFTCount):
        currTokenId = mockNFT.createToken.call({"from": account})
        currTokenIdTx = mockNFT.createToken({"from": account})
        currTokenIdTx.wait(1)
        mockNFT.safeTransferFrom(account.address, account3.address, currTokenId, {"from": account})

    mockTwoToken.approve(claimContract.address, depositAmount, {"from": account})
    claimContract.depositRewards(depositAmount, {"from": account})

    # Assert
    assert mockNFT._tokenIds() == account2NFTCount + account3NFTCount
    assert claimContract.addressToTwoTokenCanClaim(account2.address) == depositAmount * (account2NFTCount / (account2NFTCount + account3NFTCount))
    assert claimContract.addressToTwoTokenCanClaim(account3.address) == depositAmount * (account3NFTCount / (account2NFTCount + account3NFTCount))

def test_rewards_can_deposit_in_chunks():
    # Arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("This test is only for local blockchains.")

    account = get_account()
    account2 = get_account(2)
    account3 = get_account(3)
    mockTwoToken = deploy_mock_token()
    mockNFT = deploy_mock_nft()
    claimContract = deploy_claim_contract(mockNFT.address, mockTwoToken.address)

    # Act
    account2NFTCount = 15
    account3NFTCount = 5
    totalNFTs = account2NFTCount + account3NFTCount
    depositAmount = 2000

    for i in range(account2NFTCount):
        currTokenId = mockNFT.createToken.call({"from": account})
        currTokenIdTx = mockNFT.createToken({"from": account})
        currTokenIdTx.wait(1)
        mockNFT.safeTransferFrom(account.address, account2.address, currTokenId, {"from": account})

    for i in range(account3NFTCount):
        currTokenId = mockNFT.createToken.call({"from": account})
        currTokenIdTx = mockNFT.createToken({"from": account})
        currTokenIdTx.wait(1)
        mockNFT.safeTransferFrom(account.address, account3.address, currTokenId, {"from": account})

    mockTwoToken.approve(claimContract.address, depositAmount / 2, {"from": account})
    claimContract.depositRewardsInChunks(depositAmount / 2, 1, totalNFTs / 2, {"from": account})

    mockTwoToken.approve(claimContract.address, depositAmount / 2, {"from": account})
    claimContract.depositRewardsInChunks(depositAmount / 2, totalNFTs / 2 + 1, totalNFTs, {"from": account})

    # Assert
    assert mockNFT._tokenIds() == account2NFTCount + account3NFTCount
    assert claimContract.addressToTwoTokenCanClaim(account2.address) == depositAmount * (account2NFTCount / (account2NFTCount + account3NFTCount))
    assert claimContract.addressToTwoTokenCanClaim(account3.address) == depositAmount * (account3NFTCount / (account2NFTCount + account3NFTCount))    

def test_users_can_withdraw_TwoToken():
    # Arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("This test is only for local blockchains.")

    account = get_account()
    account2 = get_account(2)
    account3 = get_account(3)
    mockTwoToken = deploy_mock_token()
    mockNFT = deploy_mock_nft()
    claimContract = deploy_claim_contract(mockNFT.address, mockTwoToken.address)

    # Act
    account2NFTCount = 15
    account3NFTCount = 5
    depositAmount = 1000

    for i in range(account2NFTCount):
        currTokenId = mockNFT.createToken.call({"from": account})
        currTokenIdTx = mockNFT.createToken({"from": account})
        currTokenIdTx.wait(1)
        mockNFT.safeTransferFrom(account.address, account2.address, currTokenId, {"from": account})

    for i in range(account3NFTCount):
        currTokenId = mockNFT.createToken.call({"from": account})
        currTokenIdTx = mockNFT.createToken({"from": account})
        currTokenIdTx.wait(1)
        mockNFT.safeTransferFrom(account.address, account3.address, currTokenId, {"from": account})

    mockTwoToken.approve(claimContract.address, depositAmount, {"from": account})
    claimContract.depositRewards(depositAmount, {"from": account})

    account2InitialBalance = mockTwoToken.balanceOf(account2.address)
    account3InitialBalance = mockTwoToken.balanceOf(account3.address)
    account2CanClaimAmount = claimContract.addressToTwoTokenCanClaim(account2.address)
    account3CanClaimAmount = claimContract.addressToTwoTokenCanClaim(account3.address)

    claimContract.claimRewards({"from": account2})
    claimContract.claimRewards({"from": account3})

    # Assert
    assert mockTwoToken.balanceOf(account2.address) == account2InitialBalance + account2CanClaimAmount
    assert mockTwoToken.balanceOf(account3.address) == account3InitialBalance + account3CanClaimAmount
    assert claimContract.addressToTwoTokenCanClaim(account2.address) == 0
    assert claimContract.addressToTwoTokenCanClaim(account3.address) == 0

    with pytest.raises(exceptions.VirtualMachineError) as ex:
        claimContract.claimRewards({"from": account2})
    assert "You don't have any rewards to claim! If you have a OneNFT, please wait until the next reward deposit." in str(ex.value)
