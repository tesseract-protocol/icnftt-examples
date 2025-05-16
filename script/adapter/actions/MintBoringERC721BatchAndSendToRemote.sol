// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console, stdJson} from "forge-std/Script.sol";
import {BoringERC721} from "../../../src/adapter/BoringERC721.sol";
import {ERC721AdapterTokenHome} from "../../../src/adapter/ERC721AdapterTokenHome.sol";
import {SendTokenInput} from "@icnftt/adapter/interfaces/IERC721Transferrer.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";

/**
 * @title MintBoringERC721BatchAndSendToRemote
 * @dev A script that mints multiple NFTs using BoringERC721 and transfers them as a batch through the adapter to Remote
 *
 * To run this script:
 * forge script script/adapter/actions/MintBoringERC721BatchAndSendToRemote.sol:MintBoringERC721BatchAndSendToRemote --account tester --slow --broadcast -vvvv --rpc-url $HOME_RPC_URL --skip-simulation
 */
contract MintBoringERC721BatchAndSendToRemote is Script {
    // Path to the addresses JSON file
    string constant ADDRESSES_FILE = "script/addresses.json";

    uint256 constant GAS_LIMIT = 1500000;

    // Number of tokens to mint and send
    uint256 constant BATCH_SIZE = 3;

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
        console.log("Required Gas Limit:", GAS_LIMIT);
        console.log("Batch Size:", BATCH_SIZE);

        BoringERC721 nftToken = BoringERC721(boringERC721Address);
        ERC721AdapterTokenHome homeAdapter = ERC721AdapterTokenHome(homeAdapterAddress);

        WarpMessengerMock warp = new WarpMessengerMock();
        vm.etch(0x0200000000000000000000000000000000000005, address(warp).code);

        vm.startBroadcast(recipient);

        // Create array to store token IDs
        uint256[] memory tokenIds = new uint256[](BATCH_SIZE);

        // Mint the tokens and approve transfers
        for (uint256 i = 0; i < BATCH_SIZE; i++) {
            uint256 tokenId = nftToken.mint(recipient);
            tokenIds[i] = tokenId;
            console.log("Minted NFT with token ID:", tokenId);
        }

        // Approve the home adapter to transfer the token
        nftToken.setApprovalForAll(homeAdapterAddress, true);
        console.log("Approved all NFT transfers to adapter");

        // Send the tokens to remote chain as a batch
        SendTokenInput memory sendInput = SendTokenInput({
            destinationBlockchainID: remoteBlockchainID,
            destinationTokenTransferrerAddress: remoteAdapterAddress,
            recipient: recipient,
            primaryFeeTokenAddress: address(0),
            primaryFee: 0,
            requiredGasLimit: GAS_LIMIT
        });

        homeAdapter.send(sendInput, tokenIds);
        console.log("Batch of NFTs sent to Remote chain");

        nftToken.setApprovalForAll(homeAdapterAddress, false);
        console.log("Revoked approval for home adapter");

        vm.stopBroadcast();
    }
}
