from brownie import network, accounts, config
import eth_utils

NON_FORKED_LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["hardhat", "development", "ganache"]

LOCAL_BLOCKCHAIN_ENVIRONMENTS = NON_FORKED_LOCAL_BLOCKCHAIN_ENVIRONMENTS + [
    "mainnet-fork",
    "binance-fork",
    "matic-fork",
]

VERIFY_NETWORKS = [
    "binance",
    "ethereum",
    "fantom",
    "avalanche",
    "binance-testnet",
    "polygon-test-custom",
    "bsc-main",
    "bsc-test",
    "goerli"
]


def get_account(accountNum=1):
    if network.show_active() == "development":
        return accounts[accountNum - 1]
    else:
        fromKeyNum = f"_{accountNum}" if accountNum != 1 else ""
        return accounts.add(config["wallets"][f"from_key{fromKeyNum}"])