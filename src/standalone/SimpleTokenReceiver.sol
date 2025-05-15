// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC721SendAndCallReceiver} from "@icnftt/standalone/interfaces/IERC721SendAndCallReceiver.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title SimpleTokenReceiver
 * @dev A simple implementation of IERC721SendAndCallReceiver that receives tokens
 * from cross-chain transfers via sendAndCall and logs the associated data
 */
contract SimpleTokenReceiver is IERC721SendAndCallReceiver {
    // Event to log all data received in the receiveToken call
    event TokenReceived(
        bytes32 indexed sourceBlockchainID,
        address indexed originTokenTransferrerAddress,
        address originSenderAddress,
        address tokenAddress,
        uint256 tokenId,
        bytes payload
    );

    // Event to track successful token transfers
    event TokenTransferred(address tokenAddress, uint256 tokenId, address previousOwner, address newOwner);

    /**
     * @notice Receives a token from a cross-chain transfer and transfers it to this contract
     * @dev This implementation simply transfers the token to itself and logs all the data
     * @param sourceBlockchainID The blockchain ID the tokens were sent from
     * @param originTokenTransferrerAddress The address of the token transferrer contract on the source blockchain
     * @param originSenderAddress The address of the sender on the source blockchain
     * @param tokenAddress The address of the ERC721 token contract on this blockchain
     * @param tokenId The ID of the token being sent
     * @param payload Additional data passed from the source chain
     */
    function receiveToken(
        bytes32 sourceBlockchainID,
        address originTokenTransferrerAddress,
        address originSenderAddress,
        address tokenAddress,
        uint256 tokenId,
        bytes calldata payload
    ) external override {
        // Log all the received data
        emit TokenReceived(
            sourceBlockchainID, originTokenTransferrerAddress, originSenderAddress, tokenAddress, tokenId, payload
        );

        // Get the current owner (should be the calling contract)
        address currentOwner = msg.sender;

        // Transfer the token from the calling contract to this contract
        IERC721(tokenAddress).transferFrom(currentOwner, address(this), tokenId);

        // Log the successful token transfer
        emit TokenTransferred(tokenAddress, tokenId, currentOwner, address(this));
    }
}
