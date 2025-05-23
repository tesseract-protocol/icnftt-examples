// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721URIStorageRemoteExtension} from
    "@icnftt/standalone/TokenRemote/extensions/ERC721URIStorageRemoteExtension.sol";
import {ERC721PausableRemoteExtension} from
    "@icnftt/standalone/TokenRemote/extensions/ERC721PausableRemoteExtension.sol";
import {ERC721TokenRemote} from "@icnftt/standalone/TokenRemote/ERC721TokenRemote.sol";
import {ERC721TokenTransferrer} from "@icnftt/standalone/ERC721TokenTransferrer.sol";
import {ExtensionMessage, ExtensionMessageParams} from "@icnftt/standalone/interfaces/IERC721Transferrer.sol";
import {ERC721URIStorageExtension} from "@icnftt/standalone/extensions/ERC721URIStorageExtension.sol";
import {ERC721PausableExtension} from "@icnftt/standalone/extensions/ERC721PausableExtension.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PausableERC721URIStorageRemote is ERC721URIStorageRemoteExtension, ERC721PausableRemoteExtension {
    constructor(
        string memory name,
        string memory symbol,
        bytes32 homeChainId,
        address homeTokenAddress,
        address teleporterRegistryAddress,
        uint256 minTeleporterVersion
    ) ERC721TokenRemote(name, symbol, homeChainId, homeTokenAddress, teleporterRegistryAddress, minTeleporterVersion) {}

    function _updateExtensions(ExtensionMessage[] memory extensions) internal override {
        for (uint256 i = 0; i < extensions.length; i++) {
            if (extensions[i].key == ERC721URIStorageExtension.URI_STORAGE_EXTENSION_ID) {
                ERC721URIStorageRemoteExtension._update(extensions[i]);
            } else if (extensions[i].key == ERC721PausableExtension.PAUSABLE_EXTENSION_ID) {
                ERC721PausableRemoteExtension._update(extensions[i]);
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
        override(ERC721URIStorageRemoteExtension, ERC721PausableRemoteExtension)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _beforeTokenTransfer(address, uint256 tokenId)
        internal
        override(ERC721TokenTransferrer, ERC721PausableRemoteExtension)
    {
        super._beforeTokenTransfer(msg.sender, tokenId);
    }

    function _update(ExtensionMessage memory extension)
        internal
        override(ERC721URIStorageRemoteExtension, ERC721PausableRemoteExtension)
    {}
}
