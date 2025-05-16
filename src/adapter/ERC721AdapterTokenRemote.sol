// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721TokenRemote} from "@icnftt/adapter/TokenRemote/ERC721TokenRemote.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ERC721AdapterTokenRemote is ERC721TokenRemote, ERC721URIStorage {
    constructor(
        string memory name,
        string memory symbol,
        bytes32 homeChainId,
        address homeTokenAddress,
        address teleporterRegistryAddress,
        address teleporterManagerAddress,
        uint256 minTeleporterVersion
    )
        ERC721TokenRemote(
            name,
            symbol,
            homeChainId,
            homeTokenAddress,
            teleporterRegistryAddress,
            teleporterManagerAddress,
            minTeleporterVersion
        )
    {}

    function _processTokenMetadata(uint256 tokenId, bytes memory metadata) internal override {
        if (metadata.length > 0) {
            string memory uri = abi.decode(metadata, (string));
            _setTokenURI(tokenId, uri);
        }
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        virtual
        override(ERC721TokenRemote, ERC721)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "";
    }
}
