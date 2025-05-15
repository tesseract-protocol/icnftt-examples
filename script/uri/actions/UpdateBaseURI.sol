// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console, stdJson} from "forge-std/Script.sol";
import {ERC721URIStorageHome} from "../../../src/standalone/ERC721URIStorageHome.sol";
import {TeleporterFeeInfo} from "@teleporter/ITeleporterMessenger.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";

/**
 * To run this script:
 * forge script script/uri/actions/UpdateBaseURI.sol:UpdateBaseURI --rpc-url $HOME_RPC_URL --account deployer --broadcast --skip-simulation -vvvv
 */
contract UpdateBaseURI is Script {
    // Path to the addresses JSON file
    string constant ADDRESSES_FILE = "script/addresses.json";

    // New base URI to set
    string constant NEW_BASE_URI = "https://tesseract.finance/nft/uri/";

    using stdJson for string;

    function run() external {
        string memory json = vm.readFile(ADDRESSES_FILE);
        address homeContractAddress = json.readAddress(".erc721URIStorageHome");

        if (homeContractAddress == address(0)) {
            revert("ERC721URIStorageHome address not set in addresses.json");
        }

        console.log("Home Contract Address:", homeContractAddress);
        console.log("New Base URI:", NEW_BASE_URI);

        ERC721URIStorageHome homeToken = ERC721URIStorageHome(homeContractAddress);

        WarpMessengerMock warp = new WarpMessengerMock();
        vm.etch(0x0200000000000000000000000000000000000005, address(warp).code);

        vm.startBroadcast();

        uint256 numRegisteredChains = homeToken.getRegisteredChainsLength();
        console.log("Number of registered remote chains:", numRegisteredChains);

        if (numRegisteredChains > 0) {
            console.log("Registered chains:");
            bytes32[] memory chains = homeToken.getRegisteredChains();
            for (uint256 i = 0; i < chains.length; i++) {
                address remoteContract = homeToken.getRemoteContract(chains[i]);
                console.log("Chain", i, ":", vm.toString(chains[i]));
                console.log("Remote Contract:", remoteContract);
            }
        }

        TeleporterFeeInfo memory feeInfo = TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0});

        homeToken.updateBaseURI(
            NEW_BASE_URI,
            true, // Update all remote chains
            feeInfo
        );

        console.log("Base URI updated and propagated to all registered chains");

        vm.stopBroadcast();
    }
}
