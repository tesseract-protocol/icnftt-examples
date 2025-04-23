// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console, stdJson} from "forge-std/Script.sol";
import {BasicERC721Home} from "../../../src/BasicERC721Home.sol";
import {SendTokenInput} from "@icnftt/interfaces/IERC721Transferrer.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";

/**
 * @title MintBasicERC721AndSendToRemote
 * @dev A script that mints a new NFT using BasicERC721Home and transfers it to Remote
 *
 * To run this script:
 * forge script script/MintBasicERC721AndSendToRemote.sol:MintBasicERC721AndSendToRemote --account tester --broadcast -vvvv --rpc-url $CCHAIN_RPC_URL --skip-simulation
 */
contract MintBasicERC721AndSendToRemote is Script {
    // Path to the addresses JSON file
    string constant ADDRESSES_FILE = "script/addresses.json";

    // Default gas limit if not specified in JSON
    uint256 constant DEFAULT_GAS_LIMIT = 200000;

    using stdJson for string;

    function run() external {
        string memory json = vm.readFile(ADDRESSES_FILE);

        address basicERC721Home = json.readAddress(".basicERC721Home");
        address basicERC721Remote = json.readAddress(".basicERC721Remote");
        address recipient = json.readAddress(".fallbackRecipient"); // Using fallbackRecipient as recipient
        bytes32 remoteBlockchainID = json.readBytes32(".remoteBlockchainID");

        console.log("Home Contract Address:", basicERC721Home);
        console.log("Remote Contract Address:", basicERC721Remote);
        console.log("Recipient Address:", recipient);
        console.log("Required Gas Limit:", DEFAULT_GAS_LIMIT);

        BasicERC721Home homeToken = BasicERC721Home(basicERC721Home);

        WarpMessengerMock warp = new WarpMessengerMock();
        vm.etch(0x0200000000000000000000000000000000000005, address(warp).code);

        vm.startBroadcast();

        homeToken.mint();

        uint256 tokenId = homeToken.lastTokenId() - 1;
        console.log("Minted NFT with token ID:", tokenId);

        SendTokenInput memory sendInput = SendTokenInput({
            destinationBlockchainID: remoteBlockchainID,
            destinationTokenTransferrerAddress: basicERC721Remote,
            recipient: recipient,
            primaryFeeTokenAddress: address(0),
            primaryFee: 0,
            requiredGasLimit: DEFAULT_GAS_LIMIT
        });

        homeToken.send(sendInput, tokenId);
        console.log("NFT sent to Remote");

        vm.stopBroadcast();
    }
}
