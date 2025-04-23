// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console, stdJson} from "forge-std/Script.sol";
import {BasicERC721Remote} from "../../../src/BasicERC721Remote.sol";
import {TeleporterFeeInfo} from "@icm-contracts/teleporter/ITeleporterMessenger.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";

/**
 * To run this script:
 * forge script script/basic/deployment/DeployBasicERC721Remote.sol:DeployBasicERC721Remote --rpc-url $REMOTE_RPC_URL --account deployer --broadcast --skip-simulation -vvvv --verifier custom --verify --verifier-url 'https://api.routescan.io/v2/network/mainnet/evm/42069/etherscan' --etherscan-api-key "verifyContract"
 */
contract DeployBasicERC721Remote is Script {
    // Constants for BasicERC721Remote
    string constant REMOTE_NAME = "Basic NFT";
    string constant REMOTE_SYMBOL = "BNFT";
    uint256 constant REMOTE_MIN_TELEPORTER_VERSION = 1;
    string constant ADDRESSES_FILE = "script/addresses.json";

    using stdJson for string;

    function run() external {
        // Read configuration from JSON file
        string memory json = vm.readFile(ADDRESSES_FILE);

        // Parse addresses from JSON
        address homeContractAddress = json.readAddress(".basicERC721Home");
        address teleporterRegistry = json.readAddress(".remoteTeleporterRegistry");
        bytes32 homeBlockchainID = json.readBytes32(".homeBlockchainID");

        WarpMessengerMock warp = new WarpMessengerMock();
        vm.etch(0x0200000000000000000000000000000000000005, address(warp).code);

        console.log("Deploying BasicERC721Remote on Coqnet...");
        console.log("Using home contract address:", homeContractAddress);

        vm.startBroadcast();
        BasicERC721Remote remote = new BasicERC721Remote(
            REMOTE_NAME,
            REMOTE_SYMBOL,
            homeBlockchainID,
            homeContractAddress,
            teleporterRegistry,
            REMOTE_MIN_TELEPORTER_VERSION
        );
        remote.registerWithHome(TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}));
        vm.stopBroadcast();

        vm.writeJson(vm.toString(address(remote)), ADDRESSES_FILE, ".basicERC721Remote");

        console.log("\n=== Deployment Summary ===");
        console.log("Coqnet Remote Contract:", address(remote));
    }
}
