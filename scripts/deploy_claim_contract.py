from brownie import network, config, OneNFTClaim
from brownie.network.contract import Contract
from scripts.helpers import get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS, VERIFY_NETWORKS
from web3 import Web3
import os

ONE_NFT_ADDRESS_TEST = "0x9f72611790b5200Eea14373ed5bDE8693B35790D"
ONE_NFT_ADDRESS = ""
USDC_ADDRESS_TEST = "0x8F69f8466E34Dc47FEEffb4dFAe28cA4fA1ED85e"
USDC_ADDRESS = ""

PROD = False

def deploy_claim_contract(oneNFTAddress=None, USDCAddress=None):
    account = get_account()

    currNetwork = network.show_active()
    if PROD:
        oneNFTAddress = ONE_NFT_ADDRESS
        USDCAddress = USDC_ADDRESS
    elif not oneNFTAddress:
        oneNFTAddress = ONE_NFT_ADDRESS_TEST
        USDCAddress = USDC_ADDRESS_TEST

    publishSource = currNetwork in VERIFY_NETWORKS

    claimContract = OneNFTClaim.deploy(
        oneNFTAddress,
        USDCAddress,
        {"from": account}, publish_source=publishSource
    )
    print(f"One NFT claim contract deployed to {claimContract.address}")

    return claimContract

def main():
    deploy_claim_contract()