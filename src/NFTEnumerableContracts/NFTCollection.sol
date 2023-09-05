// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC721, ERC721Enumerable} from "@openzeppelin/contracts//token/ERC721/extensions/ERC721Enumerable.sol";

/// @title
contract NFTCollection is ERC721, ERC721Enumerable {
    
    uint8 private constant MAX_SUPPLY = 20;

    constructor() ERC721("NFTCollection", "NFTC") {}

    function safeMint() external {
        require(totalSupply() + 1 <= MAX_SUPPLY, "Beyond Max Supply");

        _safeMint(msg.sender, totalSupply() + 1);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
