// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721TokenHome} from "@icnftt/adapter/TokenHome/ERC721TokenHome.sol";
import {TransferrerMessageType} from "@icnftt/adapter/interfaces/IERC721Transferrer.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ERC721AdapterTokenHome is ERC721TokenHome {
    constructor(
        address homeTokenAddress,
        address teleporterRegistryAddress,
        address teleporterManagerAddress,
        uint256 minTeleporterVersion
    ) ERC721TokenHome(homeTokenAddress, teleporterRegistryAddress, teleporterManagerAddress, minTeleporterVersion) {}

    function _prepareTokenMetadata(uint256 tokenId, TransferrerMessageType)
        internal
        view
        override
        returns (bytes memory)
    {
        bytes memory uriData = abi.encode(ERC721(_token).tokenURI(tokenId));
        return uriData;
    }
}
