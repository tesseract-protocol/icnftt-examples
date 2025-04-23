// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721TokenRemote} from "@icnftt/TokenRemote/ERC721TokenRemote.sol";
import {ExtensionMessage} from "@icnftt/ERC721TokenTransferrer.sol";

contract BasicERC721Remote is ERC721TokenRemote {
    constructor(
        string memory name,
        string memory symbol,
        bytes32 homeBlockchainId,
        address homeContractAddress,
        address teleporterRegistry,
        uint256 minTeleporterVersion
    )
        ERC721TokenRemote(name, symbol, homeBlockchainId, homeContractAddress, teleporterRegistry, minTeleporterVersion)
    {}

    function _updateExtensions(ExtensionMessage[] memory extensions) internal override {}

    function _getExtensionMessages(uint256 tokenId) internal view override returns (ExtensionMessage[] memory) {}
}
