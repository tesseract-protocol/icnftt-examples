// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console, stdJson} from "forge-std/Script.sol";
import {ERC721URIStorageHome} from "../../../src/ERC721URIStorageHome.sol";
import {SendTokenInput} from "@icnftt/interfaces/IERC721Transferrer.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";

/**
 * To run this script:
 * forge script script/uri/actions/SendTokenToRemote.sol:SendTokenToRemote --rpc-url $HOME_RPC_URL --account deployer --broadcast --skip-simulation -vvvv
 */
contract SendTokenToRemote is Script {
    // Path to the addresses JSON file
    string constant ADDRESSES_FILE = "script/addresses.json";

    // Default gas limit
    uint256 constant REQUIRED_GAS_LIMIT = 300000;

    // Token ID to send - can be overridden via environment
    uint256 public tokenId = 0;

    using stdJson for string;

    function run() external {
        string memory json = vm.readFile(ADDRESSES_FILE);

        address homeContractAddress = json.readAddress(".erc721URIStorageHome");
        address remoteContractAddress = json.readAddress(".erc721URIStorageRemote");
        bytes32 remoteBlockchainID = json.readBytes32(".remoteBlockchainID");

        address recipient;
        if (stdJson.keyExists(json, ".fallbackRecipient")) {
            recipient = json.readAddress(".fallbackRecipient");
        } else {
            recipient = msg.sender;
        }

        console.log("Home Contract Address:", homeContractAddress);
        console.log("Remote Contract Address:", remoteContractAddress);
        console.log("Recipient Address:", recipient);
        console.log("Token ID to send:", tokenId);

        if (homeContractAddress == address(0)) {
            revert("Home contract address not set in addresses.json");
        }
        if (remoteContractAddress == address(0)) {
            revert("Remote contract address not set in addresses.json");
        }

        ERC721URIStorageHome homeToken = ERC721URIStorageHome(homeContractAddress);

        WarpMessengerMock warp = new WarpMessengerMock();
        vm.etch(0x0200000000000000000000000000000000000005, address(warp).code);

        vm.startBroadcast();

        console.log("Token URI before sending:", homeToken.tokenURI(tokenId));

        SendTokenInput memory sendInput = SendTokenInput({
            destinationBlockchainID: remoteBlockchainID,
            destinationTokenTransferrerAddress: remoteContractAddress,
            recipient: recipient,
            primaryFeeTokenAddress: address(0),
            primaryFee: 0,
            requiredGasLimit: REQUIRED_GAS_LIMIT
        });

        homeToken.send(sendInput, tokenId);
        console.log("Token sent to remote chain");

        vm.stopBroadcast();
    }
}
