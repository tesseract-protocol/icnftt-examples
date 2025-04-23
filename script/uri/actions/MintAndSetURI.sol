// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console, stdJson} from "forge-std/Script.sol";
import {ERC721URIStorageHome} from "../../../src/ERC721URIStorageHome.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";
import {TeleporterFeeInfo} from "@icm-contracts/teleporter/ITeleporterMessenger.sol";

/**
 * To run this script:
 * forge script script/uri/actions/MintAndSetURI.sol:MintAndSetURI --rpc-url $HOME_RPC_URL --account deployer --broadcast --skip-simulation -vvvv
 */
contract MintAndSetURI is Script {
    string constant ADDRESSES_FILE = "script/addresses.json";
    string constant TOKEN_URI = "yakman.json";

    using stdJson for string;

    function run() external {
        string memory json = vm.readFile(ADDRESSES_FILE);
        address homeContractAddress = json.readAddress(".erc721URIStorageHome");

        if (homeContractAddress == address(0)) {
            console.log("ERROR: ERC721URIStorageHome address not found in addresses.json!");
            console.log("Please deploy the ERC721URIStorageHome contract first.");
            revert("ERC721URIStorageHome not deployed");
        }

        WarpMessengerMock warp = new WarpMessengerMock();
        vm.etch(0x0200000000000000000000000000000000000005, address(warp).code);

        ERC721URIStorageHome home = ERC721URIStorageHome(homeContractAddress);

        console.log("Minting a new token and setting URI...");
        console.log("Home Contract Address:", homeContractAddress);

        vm.startBroadcast();

        home.mint();
        uint256 tokenId = home.lastTokenId() - 1;

        TeleporterFeeInfo memory feeInfo = TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0});

        home.updateTokenURI(
            tokenId,
            TOKEN_URI,
            true, // Update on remote chain if token is there
            feeInfo
        );

        vm.stopBroadcast();

        console.log("\n=== Operation Summary ===");
        console.log("Token ID:", tokenId);
        console.log("Token URI:", TOKEN_URI);
        console.log("Full Token URI:", string.concat(home.tokenURI(tokenId)));
    }
}
