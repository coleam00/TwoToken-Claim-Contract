#!/usr/bin/python3
from brownie import MockNFT, config, network
from scripts.helpers import get_account, VERIFY_NETWORKS

# Deploys mock NFT for testing.
def deploy_mock_nft():
    account = get_account()
    print(f"Deploying to {network.show_active()}")

    mockNFT = MockNFT.deploy({"from": account}, publish_source=network.show_active() in VERIFY_NETWORKS)

    return mockNFT

def main():
    deploy_mock_nft()