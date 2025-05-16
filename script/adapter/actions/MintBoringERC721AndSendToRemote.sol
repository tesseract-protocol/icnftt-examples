// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console, stdJson} from "forge-std/Script.sol";
import {BoringERC721} from "../../../src/adapter/BoringERC721.sol";
import {ERC721AdapterTokenHome} from "../../../src/adapter/ERC721AdapterTokenHome.sol";
import {SendTokenInput} from "@icnftt/adapter/interfaces/IERC721Transferrer.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";

/**
 * @title MintBoringERC721AndSendToRemote
 * @dev A script that mints a new NFT using BoringERC721 and transfers it through the adapter to Remote
 *
 * To run this script:
 * forge script script/adapter/actions/MintBoringERC721AndSendToRemote.sol:MintBoringERC721AndSendToRemote --slow --account tester --broadcast -vvvv --rpc-url $HOME_RPC_URL --skip-simulation
 */
contract MintBoringERC721AndSendToRemote is Script {
    // Path to the addresses JSON file
    string constant ADDRESSES_FILE = "script/addresses.json";

    // Default gas limit if not specified in JSON
    uint256 constant DEFAULT_GAS_LIMIT = 200000;

    using stdJson for string;

    function run() external {
        string memory json = vm.readFile(ADDRESSES_FILE);

        address boringERC721Address = json.readAddress(".boringERC721");
        address homeAdapterAddress = json.readAddress(".erc721AdapterTokenHome");
        address remoteAdapterAddress = json.readAddress(".erc721AdapterTokenRemote");
        address recipient = json.readAddress(".fallbackRecipient"); // Using fallbackRecipient as recipient
        bytes32 remoteBlockchainID = json.readBytes32(".remoteBlockchainID");

        console.log("Boring ERC721 Address:", boringERC721Address);
        console.log("Home Adapter Address:", homeAdapterAddress);
        console.log("Remote Adapter Address:", remoteAdapterAddress);
        console.log("Recipient Address:", recipient);
        console.log("Required Gas Limit:", DEFAULT_GAS_LIMIT);

        BoringERC721 nftToken = BoringERC721(boringERC721Address);
        ERC721AdapterTokenHome homeAdapter = ERC721AdapterTokenHome(homeAdapterAddress);

        WarpMessengerMock warp = new WarpMessengerMock();
        vm.etch(0x0200000000000000000000000000000000000005, address(warp).code);

        vm.startBroadcast(recipient);

        // Mint the token
        uint256 tokenId = nftToken.mint(recipient);
        console.log("Minted NFT with token ID:", tokenId);

        // Approve the home adapter to transfer the token
        nftToken.approve(homeAdapterAddress, tokenId);
        console.log("Approved NFT transfer to adapter");

        // Create array with single token ID
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = tokenId;

        // Send the token to remote chain
        SendTokenInput memory sendInput = SendTokenInput({
            destinationBlockchainID: remoteBlockchainID,
            destinationTokenTransferrerAddress: remoteAdapterAddress,
            recipient: recipient,
            primaryFeeTokenAddress: address(0),
            primaryFee: 0,
            requiredGasLimit: DEFAULT_GAS_LIMIT
        });

        homeAdapter.send(sendInput, tokenIds);
        console.log("NFT sent to Remote chain");

        vm.stopBroadcast();
    }
}
