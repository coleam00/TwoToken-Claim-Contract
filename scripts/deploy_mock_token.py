#!/usr/bin/python3
from brownie import MockToken, config, network
from scripts.helpers import get_account, VERIFY_NETWORKS

# Deploys mock token for testing.
def deploy_mock_token():
    account = get_account()
    print(f"Deploying to {network.show_active()}")

    mockToken = MockToken.deploy({"from": account}, publish_source=network.show_active() in VERIFY_NETWORKS)

    return mockToken

def main():
    deploy_mock_token()