# OneNFT Claim Contract for the TwoToken Protocol

The OneNFT claim contract serves as the vehicle for the TwoToken protocol owners to deposit USDC rewards for OneNFT holders and for
OneNFT holders to claim those rewards. The claim contract interacts with the OneNFT contract to determine how rewards are distributed
upon deposits based on the current holders of the NFTs. Rewards are assigned to the holder addresses, NOT the NFTs. This means that if
there is a USDC deposit for holder A and then holder A transfers the NFT to holder B, the rewards would still be claimable by holder A not holder B.
But then the next deposit would be claimable by holder B and not holder A.

# Development Environment Setup

To set up the Brownie development environment for testing and any further development, follow the instructions here provided in the Brownie documentation:

https://eth-brownie.readthedocs.io/en/stable/install.html

It's key to note here that Brownie has two requirements before the development environment is fully set up:

Python3 - https://www.python.org/downloads/release/python-368/

Ganache-CLI - https://github.com/trufflesuite/ganache-cli

# Project Information

The OneNFT claim contract was developed using the eth-brownie Python web3 framework. This repository contains the smart contract code, the
configuration for testing/deployments, the scripts used to test the contract, and the scripts used to deploy the contract.

Once the development environment is set up, to compile the smart contract code, run the command:

``brownie compile``

To run the tests for the smart contract code, run the command:

``brownie test``

Make sure the PROD variable is set to False in scripts/deploy_claim_contract.py before running any tests!

To get more verbose output when running the smart contract tests, run the command:

``brownie test -v -s``

To run just a single smart contract test, run the command:

``brownie test -v -s -k [test function name]``

# Contract Deployment Commands

To deploy the OneNFT claim contract, run the command (and more instructions below):

``brownie run scripts/deploy_claim_contract.py deploy_claim_contract --network [network name]``

IMPORTANT - Make sure that the variable values are set in scripts/deploy_claim_contract.py for a production deployment:

PROD = True
ONE_NFT_ADDRESS = [the address of the OneNFT contract on BSC]
USDC_ADDRESS = [the USDC address on BSC]

To deploy the contract to an actual blockchain (versus a local blockchain spun up with Ganache), you'll need to create a .env file at the root of the project and add the line:

``export PRIVATE_KEY=[Private key for the address you're deploying with]``

This is how Brownie is able to use your account to transact on whatever blockchain you're deploying to. To learn how to export your private key from MetaMask, visit this link:

https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-export-an-account-s-private-key

If you want to verify the contract on the explorer, and if you are deploying to a network with Infura, you also need to add these lines to the .env file:

``export BSCSCAN_TOKEN=[token for the explorer you are verifying on - the name of this variable changes depending on the network]``

``export WEB3_INFURA_PROJECT_ID=[Infura project ID]``

Also use the .env.example file for a reference when creating the .env file. For more inforamation on setting up an Infura project to get the Infura ID, check out:

https://docs.infura.io/infura/getting-started

To view the list of possible networks that can be used for the deployment and upgrade scripts, run the command:

``brownie networks list true``

To add a new network to the eth-brownie environment, run the command:

``brownie networks add [environment] [id] host=[host] chainid=[chainid] explorer=[explorer]``

View more information on eth-brownie network management here:
https://eth-brownie.readthedocs.io/en/stable/network-management.html
