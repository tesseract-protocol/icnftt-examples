// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console, stdJson} from "forge-std/Script.sol";
import {BasicERC721Home} from "../../../src/BasicERC721Home.sol";
import {TeleporterFeeInfo} from "@teleporter/ITeleporterMessenger.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";

/**
 * @title UpdateBasicERC721BaseURI
 * @dev A script that updates the base URI for NFTs in BasicERC721Home and
 *      propagates the change to all remote chains
 *
 * To run this script:
 * forge script script/UpdateBasicERC721BaseURI.sol:UpdateBasicERC721BaseURI --account deployer --broadcast -vvvv --rpc-url $CCHAIN_RPC_URL --skip-simulation
 */
contract UpdateBasicERC721BaseURI is Script {
    // Path to the addresses JSON file
    string constant ADDRESSES_FILE = "script/addresses.json";

    // New base URI to set
    string public constant NEW_BASE_URI = "https://tesseract.finance/nft/";

    using stdJson for string;

    function run() external {
        // Read configuration from JSON file
        string memory json = vm.readFile(ADDRESSES_FILE);
        address homeContractAddress = json.readAddress(".basicERC721Home");

        console.log("Home Contract Address:", homeContractAddress);
        console.log("New Base URI:", NEW_BASE_URI);

        BasicERC721Home homeToken = BasicERC721Home(homeContractAddress);

        WarpMessengerMock warp = new WarpMessengerMock();
        vm.etch(0x0200000000000000000000000000000000000005, address(warp).code);

        vm.startBroadcast();

        uint256 numRegisteredChains = homeToken.getRegisteredChainsLength();
        console.log("Number of registered remote chains:", numRegisteredChains);

        TeleporterFeeInfo memory feeInfo = TeleporterFeeInfo({
            feeTokenAddress: address(0), // No fee token (using native tokens)
            amount: 0 // No fee amount (for testnet)
        });

        homeToken.updateBaseURI(
            NEW_BASE_URI,
            true, // Update all remote chains
            feeInfo
        );

        console.log("Base URI updated and propagated to all registered chains");

        vm.stopBroadcast();

        bytes32[] memory registeredChains = homeToken.getRegisteredChains();
        if (registeredChains.length > 0) {
            console.log("\nRegistered Chains:");
            for (uint256 i = 0; i < registeredChains.length; i++) {
                address remoteContract = homeToken.getRemoteContract(registeredChains[i]);
                console.log("Chain ID:", vm.toString(registeredChains[i]));
                console.log("Remote Contract:", remoteContract);
            }
        }
    }
}
