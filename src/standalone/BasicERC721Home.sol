// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721TokenHome} from "@icnftt/standalone/TokenHome/ERC721TokenHome.sol";
import {ERC721TokenTransferrer} from "@icnftt/standalone/ERC721TokenTransferrer.sol";
import {ExtensionMessage, ExtensionMessageParams} from "@icnftt/standalone/interfaces/IERC721Transferrer.sol";

contract BasicERC721Home is ERC721TokenHome {
    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI,
        address teleporterRegistry,
        uint256 minTeleporterVersion
    ) ERC721TokenHome(name, symbol, baseURI, teleporterRegistry, minTeleporterVersion) {}

    uint256 public lastTokenId;

    function mint() external {
        _safeMint(msg.sender, lastTokenId++);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721TokenTransferrer)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _getExtensionMessages(ExtensionMessageParams memory params)
        internal
        view
        override
        returns (ExtensionMessage[] memory)
    {}
}
