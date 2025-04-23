// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721TokenRemote} from "@icnftt/TokenRemote/ERC721TokenRemote.sol";
import {ExtensionMessage} from "@icnftt/ERC721TokenTransferrer.sol";
import {ERC721URIStorageExtension, ERC721} from "@icnftt/extensions/ERC721URIStorageExtension.sol";

contract ERC721URIStorageRemote is ERC721TokenRemote, ERC721URIStorageExtension {
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

    function _baseURI() internal view override(ERC721TokenRemote, ERC721) returns (string memory) {
        return super._baseURI();
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721URIStorageExtension, ERC721)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorageExtension, ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _updateExtensions(ExtensionMessage[] memory extensions) internal override {
        for (uint256 i = 0; i < extensions.length; i++) {
            if (extensions[i].key == ERC4906_INTERFACE_ID) {
                ERC721URIStorageExtension._update(extensions[i]);
            }
        }
    }

    function _getExtensionMessages(uint256 tokenId) internal view override returns (ExtensionMessage[] memory) {
        ExtensionMessage[] memory extensionMessages = new ExtensionMessage[](1);
        extensionMessages[0] = ERC721URIStorageExtension._getMessage(tokenId);
        return extensionMessages;
    }
}
