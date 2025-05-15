// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721TokenRemote} from "@icnftt/standalone/TokenRemote/ERC721TokenRemote.sol";
import {ERC721TokenTransferrer} from "@icnftt/standalone/ERC721TokenTransferrer.sol";
import {ExtensionMessage, ExtensionMessageParams} from "@icnftt/standalone/interfaces/IERC721Transferrer.sol";

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

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721TokenTransferrer)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _updateExtensions(ExtensionMessage[] memory extensions) internal override {}
}
