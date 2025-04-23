// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console, stdJson} from "forge-std/Script.sol";
import {BasicERC721Home} from "../../../src/BasicERC721Home.sol";
import {SendAndCallInput} from "@icnftt/interfaces/IERC721Transferrer.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";

/**
 * @title MintBasicERC721AndSendAndCall
 * @dev A script that mints a new NFT using BasicERC721Home and transfers it to Remote
 * using the sendAndCall functionality, targeting a SimpleTokenReceiver contract
 *
 * To run this script:
 * forge script script/MintBasicERC721AndSendAndCall.sol:MintBasicERC721AndSendAndCall --account tester --broadcast -vvvv --rpc-url $CCHAIN_RPC_URL --skip-simulation
 */
contract MintBasicERC721AndSendAndCall is Script {
    // Path to the addresses JSON file
    string constant ADDRESSES_FILE = "script/addresses.json";

    uint256 public constant REQUIRED_GAS_LIMIT = 300000;
    uint256 public constant RECIPIENT_GAS_LIMIT = 200000;

    using stdJson for string;

    function run() external {
        // Read all addresses from the JSON file
        string memory json = vm.readFile(ADDRESSES_FILE);

        // Parse addresses from JSON using proper methods
        address homeContractAddress = json.readAddress(".basicERC721Home");
        address remoteContractAddress = json.readAddress(".basicERC721Remote");
        address fallbackRecipient = json.readAddress(".fallbackRecipient");
        bytes32 remoteBlockchainID = json.readBytes32(".remoteBlockchainID");
        address sendAndCallReceiver = json.readAddress(".sendAndCallReceiver");

        console.log("Home Contract Address:", homeContractAddress);
        console.log("Remote Contract Address:", remoteContractAddress);
        console.log("Token Receiver Address:", sendAndCallReceiver);
        console.log("Fallback Recipient:", fallbackRecipient);
        console.log("Required Gas Limit:", REQUIRED_GAS_LIMIT);
        console.log("Recipient Gas Limit:", RECIPIENT_GAS_LIMIT);

        BasicERC721Home homeToken = BasicERC721Home(homeContractAddress);

        WarpMessengerMock warp = new WarpMessengerMock();
        vm.etch(0x0200000000000000000000000000000000000005, address(warp).code);

        vm.startBroadcast();

        homeToken.mint();

        uint256 tokenId = homeToken.lastTokenId() - 1;
        console.log("Minted NFT with token ID:", tokenId);

        bytes memory recipientPayload = abi.encode("Example payload data", block.timestamp);

        SendAndCallInput memory sendInput = SendAndCallInput({
            destinationBlockchainID: remoteBlockchainID,
            destinationTokenTransferrerAddress: remoteContractAddress,
            recipientContract: sendAndCallReceiver,
            fallbackRecipient: fallbackRecipient,
            recipientPayload: recipientPayload,
            recipientGasLimit: RECIPIENT_GAS_LIMIT,
            primaryFeeTokenAddress: address(0),
            primaryFee: 0,
            requiredGasLimit: REQUIRED_GAS_LIMIT
        });

        homeToken.sendAndCall(sendInput, tokenId);
        console.log("NFT sent to Remote via sendAndCall");

        vm.stopBroadcast();
    }
}
