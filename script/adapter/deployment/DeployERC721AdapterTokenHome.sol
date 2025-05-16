// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {ERC721AdapterTokenHome} from "../../../src/adapter/ERC721AdapterTokenHome.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";

/**
 * To run this script:
 * forge script script/adapter/deployment/DeployERC721AdapterTokenHome.sol:DeployERC721AdapterTokenHome --rpc-url $HOME_RPC_URL --account deployer --broadcast --skip-simulation -vvvv --verify --verifier-url 'https://api.routescan.io/v2/network/mainnet/evm/43114/etherscan' --etherscan-api-key "verifyContract"
 */
contract DeployERC721AdapterTokenHome is Script {
    uint256 constant HOME_MIN_TELEPORTER_VERSION = 1;
    string constant ADDRESSES_FILE = "script/addresses.json";

    using stdJson for string;

    function run() external {
        string memory json = vm.readFile(ADDRESSES_FILE);
        address teleporterRegistry = json.readAddress(".homeTeleporterRegistry");
        address teleporterManager = json.readAddress(".teleporterManager");
        address homeTokenAddress = json.readAddress(".boringERC721");

        WarpMessengerMock warp = new WarpMessengerMock();
        vm.etch(0x0200000000000000000000000000000000000005, address(warp).code);

        console.log("Deploying ERC721AdapterTokenHome...");
        console.log("Using token address:", homeTokenAddress);

        vm.startBroadcast();
        ERC721AdapterTokenHome home = new ERC721AdapterTokenHome(
            homeTokenAddress, teleporterRegistry, teleporterManager, HOME_MIN_TELEPORTER_VERSION
        );
        vm.stopBroadcast();

        address homeContractAddress = address(home);

        console.log("\n=== Deployment Summary ===");
        console.log("C-Chain Home Adapter Contract: ", homeContractAddress);

        vm.writeJson(vm.toString(homeContractAddress), ADDRESSES_FILE, ".erc721AdapterTokenHome");
    }
}
