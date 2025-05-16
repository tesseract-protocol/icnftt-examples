// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {BoringERC721} from "../../../src/adapter/BoringERC721.sol";

/**
 * To run this script:
 * forge script script/adapter/deployment/DeployBoringERC721.sol:DeployBoringERC721 --rpc-url $HOME_RPC_URL --account deployer --broadcast --skip-simulation -vvvv --verify --verifier-url 'https://api.routescan.io/v2/network/mainnet/evm/43114/etherscan' --etherscan-api-key "verifyContract"
 */
contract DeployBoringERC721 is Script {
    string constant TOKEN_NAME = "Boring NFT";
    string constant TOKEN_SYMBOL = "BORING";
    string constant BASE_URI = "https://tesseract.finance/nft/";
    string constant ADDRESSES_FILE = "script/addresses.json";

    using stdJson for string;

    function run() external {
        console.log("Deploying BoringERC721...");

        vm.startBroadcast();
        BoringERC721 token = new BoringERC721(TOKEN_NAME, TOKEN_SYMBOL, BASE_URI);
        vm.stopBroadcast();

        address tokenAddress = address(token);

        console.log("\n=== Deployment Summary ===");
        console.log("BoringERC721: ", tokenAddress);

        vm.writeJson(vm.toString(tokenAddress), ADDRESSES_FILE, ".boringERC721");
    }
}
