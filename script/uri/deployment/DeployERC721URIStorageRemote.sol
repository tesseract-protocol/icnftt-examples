// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console, stdJson} from "forge-std/Script.sol";
import {ERC721URIStorageRemote} from "../../../src/standalone/ERC721URIStorageRemote.sol";
import {TeleporterFeeInfo} from "@icm-contracts/teleporter/ITeleporterMessenger.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";

/**
 * To run this script:
 * forge script script/uri/deployment/DeployERC721URIStorageRemote.sol:DeployERC721URIStorageRemote --rpc-url $REMOTE_RPC_URL --account deployer --broadcast --skip-simulation -vvvv --verifier custom --verify --verifier-url 'https://api.routescan.io/v2/network/mainnet/evm/42069/etherscan' --etherscan-api-key "verifyContract"
 */
contract DeployERC721URIStorageRemote is Script {
    // Constants for ERC721URIStorageRemote
    string constant REMOTE_NAME = "URI NFT";
    string constant REMOTE_SYMBOL = "UNFT";
    uint256 constant REMOTE_MIN_TELEPORTER_VERSION = 1;
    string constant ADDRESSES_FILE = "script/addresses.json";

    using stdJson for string;

    function run() external {
        // Read configuration from JSON file
        string memory json = vm.readFile(ADDRESSES_FILE);

        // Parse addresses from JSON
        address homeContractAddress = json.readAddress(".erc721URIStorageHome");
        address teleporterRegistry = json.readAddress(".remoteTeleporterRegistry");
        bytes32 homeBlockchainID = json.readBytes32(".homeBlockchainID");

        // If the home contract address is not in JSON, we need to alert the user
        if (homeContractAddress == address(0)) {
            console.log("ERROR: ERC721URIStorageHome address not found in addresses.json!");
            console.log("Please deploy the ERC721URIStorageHome contract first.");
            revert("ERC721URIStorageHome not deployed");
        }

        WarpMessengerMock warp = new WarpMessengerMock();
        vm.etch(0x0200000000000000000000000000000000000005, address(warp).code);

        console.log("Deploying ERC721URIStorageRemote...");
        console.log("Using home contract address:", homeContractAddress);

        vm.startBroadcast();
        ERC721URIStorageRemote remote = new ERC721URIStorageRemote(
            REMOTE_NAME,
            REMOTE_SYMBOL,
            homeBlockchainID,
            homeContractAddress,
            teleporterRegistry,
            REMOTE_MIN_TELEPORTER_VERSION
        );
        remote.registerWithHome(TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}));
        vm.stopBroadcast();

        address remoteContractAddress = address(remote);

        vm.writeJson(vm.toString(remoteContractAddress), ADDRESSES_FILE, ".erc721URIStorageRemote");

        console.log("\n=== Deployment Summary ===");
        console.log("Remote URI Contract:", remoteContractAddress);
    }
}

// forge verify-contract 0x4001efe66331587b9e18a1E84bB9584011157c5c src/ERC721URIStorageRemote.sol:ERC721URIStorageRemote \
// --etherscan-api-key "verifyContract" \
// --compiler-version 0.8.25 \
// --optimizer-runs 200 \
// --constructor-args 00000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000001000427d4b22a2a78bcddd456742caf91b56badbff985ee19aef14573e7343fd65200000000000000000000000009199dab1e27a0ef72b6d11dd70abd5de962c786000000000000000000000000e329b5ff445e4976821fdca99d6897ec43891a6c00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000007555249204e4654000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004554e465400000000000000000000000000000000000000000000000000000000 \
// --verifier-url "https://api.routescan.io/v2/network/mainnet/evm/42069/etherscan"
