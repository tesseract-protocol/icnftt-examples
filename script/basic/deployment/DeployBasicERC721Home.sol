// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {BasicERC721Home} from "../../../src/standalone/BasicERC721Home.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";
import {stdJson} from "forge-std/StdJson.sol";

/**
 * To run this script:
 * forge script script/basic/deployment/DeployBasicERC721Home.sol:DeployBasicERC721Home --rpc-url $HOME_RPC_URL --account deployer --broadcast --skip-simulation -vvvv --verify --verifier-url 'https://api.routescan.io/v2/network/mainnet/evm/43114/etherscan' --etherscan-api-key "verifyContract"
 */
contract DeployBasicERC721Home is Script {
    string constant HOME_NAME = "Basic NFT";
    string constant HOME_SYMBOL = "BNFT";
    string constant HOME_BASE_URI = "https://example.com/nft/";
    uint256 constant HOME_MIN_TELEPORTER_VERSION = 1;

    string constant ADDRESSES_FILE = "script/addresses.json";

    using stdJson for string;

    function run() external {
        string memory json = vm.readFile(ADDRESSES_FILE);
        address teleporterRegistry = json.readAddress(".homeTeleporterRegistry");

        WarpMessengerMock warp = new WarpMessengerMock();
        vm.etch(0x0200000000000000000000000000000000000005, address(warp).code);

        vm.startBroadcast();
        BasicERC721Home home =
            new BasicERC721Home(HOME_NAME, HOME_SYMBOL, HOME_BASE_URI, teleporterRegistry, HOME_MIN_TELEPORTER_VERSION);
        vm.stopBroadcast();

        address homeContractAddress = address(home);

        console.log("\n=== Deployment Summary ===");
        console.log("C-Chain Home Contract: ", homeContractAddress);

        vm.writeJson(vm.toString(homeContractAddress), ADDRESSES_FILE, ".basicERC721Home");
    }
}
