// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721TokenRemote} from "@icnftt/standalone/TokenRemote/ERC721TokenRemote.sol";
import {ERC721URIStorageRemoteExtension} from
    "@icnftt/standalone/TokenRemote/extensions/ERC721URIStorageRemoteExtension.sol";
import {ERC721TokenTransferrer} from "@icnftt/standalone/ERC721TokenTransferrer.sol";
import {ExtensionMessageParams, ExtensionMessage} from "@icnftt/standalone/interfaces/IERC721Transferrer.sol";
import {ERC721URIStorageExtension} from "@icnftt/standalone/extensions/ERC721URIStorageExtension.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ERC721URIStorageRemote is ERC721TokenRemote, ERC721URIStorageRemoteExtension {
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

    function _updateExtensions(ExtensionMessage[] memory extensions) internal override {
        for (uint256 i = 0; i < extensions.length; i++) {
            if (extensions[i].key == ERC721URIStorageExtension.URI_STORAGE_EXTENSION_ID) {
                ERC721URIStorageRemoteExtension._update(extensions[i]);
            }
        }
    }

    function _baseURI()
        internal
        view
        override(ERC721URIStorageRemoteExtension, ERC721TokenTransferrer)
        returns (string memory)
    {
        return super._baseURI();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorageRemoteExtension, ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721URIStorageRemoteExtension, ERC721)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721URIStorageRemoteExtension, ERC721TokenTransferrer)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _beforeTokenTransfer(address, uint256 tokenId) internal override(ERC721TokenTransferrer) {
        super._beforeTokenTransfer(msg.sender, tokenId);
    }

    function _update(ExtensionMessage memory extension) internal override(ERC721URIStorageRemoteExtension) {}
}
