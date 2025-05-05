// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721URIStorageRemoteExtension} from "@icnftt/TokenRemote/extensions/ERC721URIStorageRemoteExtension.sol";
import {ERC721PausableRemoteExtension} from "@icnftt/TokenRemote/extensions/ERC721PausableRemoteExtension.sol";
import {ERC721TokenRemote} from "@icnftt/TokenRemote/ERC721TokenRemote.sol";
import {ERC721TokenTransferrer} from "@icnftt/ERC721TokenTransferrer.sol";
import {ExtensionMessage, ExtensionMessageParams} from "@icnftt/ERC721TokenTransferrer.sol";
import {ERC721URIStorageExtension} from "@icnftt/extensions/ERC721URIStorageExtension.sol";
import {ERC721PausableExtension} from "@icnftt/extensions/ERC721PausableExtension.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {CreatorTokenBase} from "@limitbreak/creator-token-standards/src/utils/CreatorTokenBase.sol";
import {AutomaticValidatorTransferApproval} from
    "@limitbreak/creator-token-standards/src/utils/AutomaticValidatorTransferApproval.sol";
import {TOKEN_TYPE_ERC721} from "@limitbreak/creator-token-standards/lib/PermitC/src/Constants.sol";
import {ICreatorToken} from "@limitbreak/creator-token-standards/src/interfaces/ICreatorToken.sol";
import {ICreatorTokenLegacy} from "@limitbreak/creator-token-standards/src/interfaces/ICreatorTokenLegacy.sol";

contract CreatorTokenStandardERC721Remote is
    CreatorTokenBase,
    AutomaticValidatorTransferApproval,
    ERC721URIStorageRemoteExtension,
    ERC721PausableRemoteExtension
{
    constructor(
        string memory name,
        string memory symbol,
        bytes32 homeChainId,
        address homeTokenAddress,
        address teleporterRegistryAddress,
        uint256 minTeleporterVersion
    ) ERC721TokenRemote(name, symbol, homeChainId, homeTokenAddress, teleporterRegistryAddress, minTeleporterVersion) {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorageRemoteExtension, ERC721)
        returns (bool)
    {
        return interfaceId == type(ICreatorToken).interfaceId || interfaceId == type(ICreatorTokenLegacy).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721URIStorageRemoteExtension, ERC721)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override(ERC721, IERC721)
        returns (bool isApproved)
    {
        isApproved = super.isApprovedForAll(owner, operator);

        if (!isApproved) {
            if (autoApproveTransfersFromValidator) {
                isApproved = operator == address(getTransferValidator());
            }
        }
    }

    function getTransferValidationFunction() external pure returns (bytes4 functionSignature, bool isViewFunction) {
        functionSignature = bytes4(keccak256("validateTransfer(address,address,address,uint256)"));
        isViewFunction = true;
    }

    function _updateExtensions(ExtensionMessage[] memory extensions) internal override {
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

    function _baseURI()
        internal
        view
        override(ERC721URIStorageRemoteExtension, ERC721TokenTransferrer)
        returns (string memory)
    {
        return super._baseURI();
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721URIStorageRemoteExtension, ERC721PausableRemoteExtension)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _beforeTokenTransfer(address to, uint256 tokenId)
        internal
        virtual
        override(ERC721TokenTransferrer, ERC721PausableRemoteExtension)
    {
        super._beforeTokenTransfer(to, tokenId);
        address from = _ownerOf(tokenId);
        _validateBeforeTransfer(from, to, tokenId);
    }

    function _afterTokenTransfer(address from, address to, uint256 tokenId)
        internal
        virtual
        override(ERC721TokenTransferrer)
    {
        super._afterTokenTransfer(from, to, tokenId);
        _validateAfterTransfer(from, to, tokenId);
    }

    function _requireCallerIsContractOwner() internal view virtual override {
        _checkOwner();
    }

    function _tokenType() internal pure override returns (uint16) {
        return uint16(TOKEN_TYPE_ERC721);
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
