// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "forge-std/Script.sol";

contract WarpMessengerMock {
    function getBlockchainID() external returns (bytes32 blockchainID) {}
    function sendWarpMessage(bytes calldata payload) external returns (bytes32 messageID) {}
}
