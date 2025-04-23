// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721TokenHome} from "@icnftt/TokenHome/ERC721TokenHome.sol";
import {ExtensionMessage} from "@icnftt/ERC721TokenTransferrer.sol";

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

    function _updateExtensions(ExtensionMessage[] memory extensions) internal override {}

    function _getExtensionMessages(uint256 tokenId) internal view override returns (ExtensionMessage[] memory) {}
}
