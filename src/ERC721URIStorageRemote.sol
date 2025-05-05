// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721TokenRemote} from "@icnftt/TokenRemote/ERC721TokenRemote.sol";
import {ERC721URIStorageRemoteExtension} from "@icnftt/TokenRemote/extensions/ERC721URIStorageRemoteExtension.sol";
import {ERC721TokenTransferrer} from "@icnftt/ERC721TokenTransferrer.sol";
import {ExtensionMessage} from "@icnftt/ERC721TokenTransferrer.sol";
import {ExtensionMessageParams} from "@icnftt/interfaces/IERC721Transferrer.sol";
import {ERC721URIStorageExtension} from "@icnftt/extensions/ERC721URIStorageExtension.sol";
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

    function _baseURI()
        internal
        view
        override(ERC721URIStorageRemoteExtension, ERC721TokenTransferrer)
        returns (string memory)
    {
        return super._baseURI();
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721URIStorageRemoteExtension, ERC721)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorageRemoteExtension, ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721TokenTransferrer, ERC721URIStorageRemoteExtension)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _updateExtensions(ExtensionMessage[] memory extensions) internal override {
        for (uint256 i = 0; i < extensions.length; i++) {
            if (extensions[i].key == ERC4906_INTERFACE_ID) {
                ERC721URIStorageExtension._update(extensions[i]);
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
}
