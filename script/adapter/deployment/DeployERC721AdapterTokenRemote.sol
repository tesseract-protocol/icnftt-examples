// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console, stdJson} from "forge-std/Script.sol";
import {ERC721AdapterTokenRemote} from "../../../src/adapter/ERC721AdapterTokenRemote.sol";
import {TeleporterFeeInfo} from "@icm-contracts/teleporter/ITeleporterMessenger.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";

/**
 * To run this script:
 * forge script script/adapter/deployment/DeployERC721AdapterTokenRemote.sol:DeployERC721AdapterTokenRemote --rpc-url $REMOTE_RPC_URL --account deployer --broadcast --skip-simulation -vvvv --verifier custom --verify --verifier-url 'https://api.routescan.io/v2/network/mainnet/evm/42069/etherscan' --etherscan-api-key "verifyContract"
 */
contract DeployERC721AdapterTokenRemote is Script {
    // Constants for ERC721AdapterTokenRemote
    string constant REMOTE_NAME = "Boring NFT";
    string constant REMOTE_SYMBOL = "BORING";
    uint256 constant REMOTE_MIN_TELEPORTER_VERSION = 1;
    string constant ADDRESSES_FILE = "script/addresses.json";

    using stdJson for string;

    function run() external {
        // Read configuration from JSON file
        string memory json = vm.readFile(ADDRESSES_FILE);

        // Parse addresses from JSON
        address homeContractAddress = json.readAddress(".erc721AdapterTokenHome");
        address teleporterRegistry = json.readAddress(".remoteTeleporterRegistry");
        address teleporterManager = json.readAddress(".teleporterManager");
        bytes32 homeBlockchainID = json.readBytes32(".homeBlockchainID");

        WarpMessengerMock warp = new WarpMessengerMock();
        vm.etch(0x0200000000000000000000000000000000000005, address(warp).code);

        console.log("Deploying ERC721AdapterTokenRemote on Coqnet...");
        console.log("Using home contract address:", homeContractAddress);

        vm.startBroadcast();
        ERC721AdapterTokenRemote remote = new ERC721AdapterTokenRemote(
            REMOTE_NAME,
            REMOTE_SYMBOL,
            homeBlockchainID,
            homeContractAddress,
            teleporterRegistry,
            teleporterManager,
            REMOTE_MIN_TELEPORTER_VERSION
        );
        remote.registerWithHome(TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}));
        vm.stopBroadcast();

        address remoteAddress = address(remote);

        vm.writeJson(vm.toString(remoteAddress), ADDRESSES_FILE, ".erc721AdapterTokenRemote");

        console.log("\n=== Deployment Summary ===");
        console.log("Coqnet Remote Adapter Contract:", remoteAddress);
    }
}
