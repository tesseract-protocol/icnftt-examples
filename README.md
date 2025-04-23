# ICNFTT Examples

This repository contains example contracts and scripts for working with the ICNFTT (Inter-Chain NFT) framework for transferring NFTs between Avalanche L1 chains.

## Overview

The ICNFTT framework enables cross-chain transfers of ERC721 tokens between Avalanche L1 networks using Avalanche's Interchain Messaging (ICM) via Teleporter. This repository provides simple examples to demonstrate:

1. Basic ERC721 token contracts for home and remote chains
2. Minting NFTs
3. Sending NFTs across chains
4. Sending NFTs with contract calls (sendAndCall functionality)

## Contracts

### BasicERC721Home

A simple implementation of the ERC721TokenHome contract that:

- Mints new NFTs
- Allows sending NFTs to other Avalanche L1 chains
- Receives NFTs back from other chains

### BasicERC721Remote

A simple implementation of the ERC721TokenRemote contract that:

- Represents tokens on a remote chain
- Can send tokens back to the home chain

### SimpleTokenReceiver

A simple implementation of the IERC721SendAndCallReceiver interface that:

- Receives tokens from cross-chain sendAndCall operations
- Logs all received data via events
- Transfers tokens to itself
- Provides a method to withdraw tokens if needed

## Configuration

The repository uses a central JSON configuration file to store contract addresses and other configuration values:

### addresses.json

Located in the `script` directory, this file contains:

- Contract addresses for both home and remote chains
- Blockchain ID for the remote chain (Coqnet)
- Recipient addresses
- Gas limit configurations

All scripts read from this file to avoid hardcoding values. The deployment scripts also update this file when new contracts are deployed.

## Scripts

### Basic ERC721 Contracts

#### DeployBasicERC721Home

Deploys the BasicERC721Home contract to the C-Chain.

```bash
forge script script/DeployBasicERC721Home.sol:DeployBasicERC721Home --account deployer --broadcast -vvvv
```

#### DeployBasicERC721Remote

Deploys the BasicERC721Remote contract to Coqnet and registers it with the home contract.

```bash
forge script script/DeployBasicERC721Remote.sol:DeployBasicERC721Remote --account deployer --broadcast -vvvv
```

#### DeploySimpleTokenReceiver

Deploys the SimpleTokenReceiver contract to Coqnet for receiving cross-chain NFTs.

```bash
forge script script/DeploySimpleTokenReceiver.sol:DeploySimpleTokenReceiver --account deployer --broadcast -vvvv
```

#### MintAndSendToCoqnet

Mints a new NFT on the home chain and sends it to Coqnet.

```bash
forge script script/MintAndSendToCoqnet.sol:MintAndSendToCoqnet --account deployer --broadcast -vvvv
```

#### MintAndSendAndCall

Mints a new NFT on the home chain and transfers it to Coqnet using the sendAndCall functionality, targeting the SimpleTokenReceiver contract.

```bash
forge script script/MintAndSendAndCall.sol:MintAndSendAndCall --account deployer --broadcast -vvvv
```

#### UpdateBaseURI

Updates the base URI for all NFTs in the BasicERC721Home contract and propagates the change to all registered remote chains.

```bash
forge script script/UpdateBaseURI.sol:UpdateBaseURI --account deployer --broadcast -vvvv
```

### ERC721 URI Storage Contracts

This repository also includes contracts and scripts for ERC721 tokens with URI storage capabilities.

#### DeployERC721URIStorageHome

Deploys the ERC721URIStorageHome contract to the C-Chain.

```bash
forge script script/uri/deployment/DeployERC721URIStorageHome.sol:DeployERC721URIStorageHome --account deployer --broadcast -vvvv
```

#### DeployERC721URIStorageRemote

Deploys the ERC721URIStorageRemote contract to Coqnet and registers it with the home contract.

```bash
forge script script/uri/deployment/DeployERC721URIStorageRemote.sol:DeployERC721URIStorageRemote --account deployer --broadcast -vvvv
```

#### MintAndSetURI

Mints a new NFT on the home chain and sets its token URI.

```bash
forge script script/uri/actions/MintAndSetURI.sol:MintAndSetURI --account deployer --broadcast -vvvv
```

#### SendTokenToRemote

Sends a token with its URI metadata from the home chain to Coqnet.

```bash
forge script script/uri/actions/SendTokenToRemote.sol:SendTokenToRemote --account deployer --broadcast -vvvv
```

#### UpdateBaseURI (URI Storage version)

Updates the base URI for all NFTs in the ERC721URIStorageHome contract and propagates the change to all registered remote chains.

```bash
forge script script/uri/actions/UpdateBaseURI.sol:UpdateBaseURI --account deployer --broadcast -vvvv
```

## Setup

1. Install Foundry:

   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/icnftt-examples.git
   cd icnftt-examples
   ```

3. Install dependencies:

   ```bash
   forge install
   ```

4. Set up configuration:

   ```bash
   # Copy and rename the sample configuration file
   cp script/addresses.json.sample script/addresses.json

   # Edit addresses.json and set the following required variables:
   # - homeBlockchainID: The blockchain ID of your home chain (e.g., C-Chain)
   #   Example: "0x0427d4b22a2a78bcddd456742caf91b56badbff985ee19aef14573e7343fd652"
   # - homeTeleporterRegistry: The Teleporter registry address on the home chain
   #   Example: "0x7C43605E14F391720e1b37E49C78C4b03A488d98"
   # - remoteBlockchainID: The blockchain ID of your remote chain (e.g., Coqnet)
   #   Example: "0x898b8aa8353f2b79ee1de07c36474fcee339003d90fa06ea3a90d9e88b7d7c33"
   # - remoteTeleporterRegistry: The Teleporter registry address on the remote chain
   #   Example: "0xE329B5Ff445E4976821FdCa99D6897EC43891A6c"
   ```

5. Set up environment variables:

   ```bash
   # Create a .env file and add:
   CCHAIN_RPC_URL=https://api.avax.network/ext/bc/C/rpc
   COQNET_RPC_URL=https://subnets.avax.network/coqnet/mainnet/rpc
   ```

## Usage Flow

### Basic ERC721 Flow

1. Deploy the home contract:

   ```bash
   forge script script/DeployBasicERC721Home.sol:DeployBasicERC721Home --account deployer --broadcast -vvvv
   ```

2. Deploy the remote contract:

   ```bash
   forge script script/DeployBasicERC721Remote.sol:DeployBasicERC721Remote --account deployer --broadcast -vvvv
   ```

3. Deploy the token receiver contract (for sendAndCall operations):

   ```bash
   forge script script/DeploySimpleTokenReceiver.sol:DeploySimpleTokenReceiver --account deployer --broadcast -vvvv
   ```

4. Mint and send an NFT (basic transfer):

   ```bash
   forge script script/MintAndSendToCoqnet.sol:MintAndSendToCoqnet --account deployer --broadcast -vvvv
   ```

5. Mint and sendAndCall an NFT (with contract interaction):

   ```bash
   forge script script/MintAndSendAndCall.sol:MintAndSendAndCall --account deployer --broadcast -vvvv
   ```

6. (Optional) Update the base URI for all NFTs and propagate to remote chains:
   ```bash
   forge script script/UpdateBaseURI.sol:UpdateBaseURI --account deployer --broadcast -vvvv
   ```

### ERC721 URI Storage Flow

1. Deploy the URI storage home contract:

   ```bash
   forge script script/uri/deployment/DeployERC721URIStorageHome.sol:DeployERC721URIStorageHome --account deployer --broadcast -vvvv
   ```

2. Deploy the URI storage remote contract:

   ```bash
   forge script script/uri/deployment/DeployERC721URIStorageRemote.sol:DeployERC721URIStorageRemote --account deployer --broadcast -vvvv
   ```

3. Mint a token and set its URI:

   ```bash
   forge script script/uri/actions/MintAndSetURI.sol:MintAndSetURI --account deployer --broadcast -vvvv
   ```

4. Send the token to the remote chain (preserving its URI):

   ```bash
   forge script script/uri/actions/SendTokenToRemote.sol:SendTokenToRemote --account deployer --broadcast -vvvv
   ```

5. (Optional) Update the base URI for all tokens across all chains:
   ```bash
   forge script script/uri/actions/UpdateBaseURI.sol:UpdateBaseURI --account deployer --broadcast -vvvv
   ```

## License

MIT
