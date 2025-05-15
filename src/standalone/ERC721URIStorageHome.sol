// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721TokenHome} from "@icnftt/standalone/TokenHome/ERC721TokenHome.sol";
import {ERC721TokenTransferrer} from "@icnftt/standalone/ERC721TokenTransferrer.sol";
import {ExtensionMessageParams, ExtensionMessage} from "@icnftt/standalone/interfaces/IERC721Transferrer.sol";
import {ERC721URIStorageHomeExtension} from "@icnftt/standalone/TokenHome/extensions/ERC721URIStorageHomeExtension.sol";
import {ERC721URIStorageExtension} from "@icnftt/standalone/extensions/ERC721URIStorageExtension.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ERC721URIStorageHome is ERC721URIStorageHomeExtension {
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

    function _getExtensionMessages(ExtensionMessageParams memory params)
        internal
        view
        override
        returns (ExtensionMessage[] memory)
    {
        ExtensionMessage[] memory extensionMessages = new ExtensionMessage[](1);
        extensionMessages[0] = ERC721URIStorageHomeExtension._getMessage(params);
        return extensionMessages;
    }

    function _beforeTokenTransfer(address, uint256 tokenId) internal override(ERC721TokenTransferrer) {
        super._beforeTokenTransfer(msg.sender, tokenId);
    }

    function _baseURI() internal view override(ERC721URIStorageHomeExtension) returns (string memory) {
        return super._baseURI();
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721URIStorageHomeExtension) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721URIStorageHomeExtension) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721URIStorageHomeExtension)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _getMessage(ExtensionMessageParams memory params)
        internal
        view
        override(ERC721URIStorageHomeExtension)
        returns (ExtensionMessage memory)
    {}
}
