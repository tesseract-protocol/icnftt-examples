// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console, stdJson} from "forge-std/Script.sol";
import {BoringERC721} from "../../../src/adapter/BoringERC721.sol";
import {ERC721AdapterTokenRemote} from "../../../src/adapter/ERC721AdapterTokenRemote.sol";
import {SendTokenInput} from "@icnftt/adapter/interfaces/IERC721Transferrer.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";

/**
 * @title SendERC721FromRemoteToHome
 * @dev A script that sends an NFT from Remote chain back to Home chain through the adapter
 *
 * To run this script:
 * forge script script/adapter/actions/SendERC721FromRemoteToHome.sol:SendERC721FromRemoteToHome --slow --account tester --broadcast -vvvv --rpc-url $REMOTE_RPC_URL --skip-simulation
 */
contract SendERC721FromRemoteToHome is Script {
    // Path to the addresses JSON file
    string constant ADDRESSES_FILE = "script/addresses.json";

    // Default gas limit if not specified in JSON
    uint256 constant DEFAULT_GAS_LIMIT = 200000;

    // Token ID to send back
    uint256 constant TOKEN_ID = 2;

    using stdJson for string;

    function run() external {
        string memory json = vm.readFile(ADDRESSES_FILE);

        address homeAdapterAddress = json.readAddress(".erc721AdapterTokenHome");
        address remoteAdapterAddress = json.readAddress(".erc721AdapterTokenRemote");
        address recipient = json.readAddress(".fallbackRecipient"); // Using fallbackRecipient as recipient
        bytes32 homeBlockchainID = json.readBytes32(".homeBlockchainID");

        console.log("Home Adapter Address:", homeAdapterAddress);
        console.log("Remote Adapter Address:", remoteAdapterAddress);
        console.log("Recipient Address:", recipient);
        console.log("Required Gas Limit:", DEFAULT_GAS_LIMIT);

        ERC721AdapterTokenRemote remoteAdapter = ERC721AdapterTokenRemote(remoteAdapterAddress);

        WarpMessengerMock warp = new WarpMessengerMock();
        vm.etch(0x0200000000000000000000000000000000000005, address(warp).code);

        vm.startBroadcast(recipient);

        // Create array with single token ID
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = TOKEN_ID;

        // Send the token back to home chain
        SendTokenInput memory sendInput = SendTokenInput({
            destinationBlockchainID: homeBlockchainID,
            destinationTokenTransferrerAddress: homeAdapterAddress,
            recipient: recipient,
            primaryFeeTokenAddress: address(0),
            primaryFee: 0,
            requiredGasLimit: DEFAULT_GAS_LIMIT
        });

        remoteAdapter.send(sendInput, tokenIds);
        console.log("NFT sent back to Home chain");

        vm.stopBroadcast();
    }
}
