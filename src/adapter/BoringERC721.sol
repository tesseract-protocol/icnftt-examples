// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract BoringERC721 is ERC721, ERC721URIStorage {
    string private _baseURIStorage;
    uint256 private lastTokenId;

    constructor(string memory name, string memory symbol, string memory baseURI) ERC721(name, symbol) {
        _baseURIStorage = baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURIStorage;
    }

    function mint(address to) public returns (uint256) {
        _mint(to, ++lastTokenId);
        return lastTokenId;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
