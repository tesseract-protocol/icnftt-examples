// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721URIStorageHomeExtension} from "@icnftt/TokenHome/extensions/ERC721URIStorageHomeExtension.sol";
import {ERC721PausableHomeExtension} from "@icnftt/TokenHome/extensions/ERC721PausableHomeExtension.sol";
import {ERC721TokenHome} from "@icnftt/TokenHome/ERC721TokenHome.sol";
import {ERC721TokenTransferrer} from "@icnftt/ERC721TokenTransferrer.sol";
import {ExtensionMessage, ExtensionMessageParams} from "@icnftt/ERC721TokenTransferrer.sol";
import {ERC721URIStorageExtension} from "@icnftt/extensions/ERC721URIStorageExtension.sol";
import {ERC721PausableExtension} from "@icnftt/extensions/ERC721PausableExtension.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PausableERC721URIStorageHome is ERC721URIStorageHomeExtension, ERC721PausableHomeExtension {
    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI,
        address teleporterRegistryAddress,
        uint256 minTeleporterVersion
    ) ERC721TokenHome(name, symbol, baseURI, teleporterRegistryAddress, minTeleporterVersion) {}

    function mint(address to, uint256 tokenId, string memory _tokenURI) external {
        _mint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
    }

    function _updateExtensions(ExtensionMessage[] memory extensions) internal override(ERC721TokenTransferrer) {
        for (uint256 i = 0; i < extensions.length; i++) {
            if (extensions[i].key == ERC721URIStorageExtension.URI_STORAGE_EXTENSION_ID) {
                ERC721URIStorageExtension._update(extensions[i]);
            } else if (extensions[i].key == ERC721PausableExtension.PAUSABLE_EXTENSION_ID) {
                ERC721PausableExtension._update(extensions[i]);
            }
        }
    }

    function _getExtensionMessages(ExtensionMessageParams memory params)
        internal
        view
        override
        returns (ExtensionMessage[] memory)
    {
        ExtensionMessage[] memory extensionMessages = new ExtensionMessage[](1);
        extensionMessages[0] = ERC721URIStorageExtension._getMessage(params);
        return extensionMessages;
    }

    function _beforeTokenTransfer(address, uint256 tokenId)
        internal
        override(ERC721TokenTransferrer, ERC721PausableHomeExtension)
    {
        super._beforeTokenTransfer(msg.sender, tokenId);
    }

    function _baseURI()
        internal
        view
        override(ERC721URIStorageHomeExtension, ERC721TokenTransferrer)
        returns (string memory)
    {
        return super._baseURI();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorageHomeExtension, ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721URIStorageHomeExtension, ERC721)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721TokenTransferrer, ERC721URIStorageHomeExtension)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _getMessage(ExtensionMessageParams memory params)
        internal
        view
        override(ERC721URIStorageExtension, ERC721PausableExtension)
        returns (ExtensionMessage memory)
    {}

    function _update(ExtensionMessage memory extension)
        internal
        override(ERC721URIStorageExtension, ERC721PausableExtension)
    {}
}
