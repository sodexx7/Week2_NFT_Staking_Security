// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {NFTCollection} from "src/NFTEnumerableContracts/NFTCollection.sol";

contract NFTGame {
    NFTCollection private immutable _nFTCollection;

    constructor(address nFTCollection) {
        _nFTCollection = NFTCollection(nFTCollection);
    }

    /**
     * @notice Calculate how many NFTs are owned by the owner which have tokenIDs that are prime numbers.
     * @param owner  owner address
     * TODO?
     * 1. the owner has huge amounts of NFT? how to deal with the loop
     */
    function calculateNumsOfPrimeNFT(address owner) external view returns (uint256) {
        uint256 amounts = _nFTCollection.balanceOf(owner);
        uint256 totalPrimeCounts;
        // i=0 => tokenID=0 ,just ignore
        uint256 i = 1;
        for (i; i < amounts;) {
            uint256 tokenId = _nFTCollection.tokenOfOwnerByIndex(owner, i);
            if (isPrime(tokenId)) {
                unchecked {
                    ++totalPrimeCounts;
                }
            }
            unchecked {
                ++i;
            }
        }
        return totalPrimeCounts;
    }

    // dig more ?? 
    function isPrime(uint256 x) internal pure returns (bool p) {
        p = true;
        assembly {
            let halfX := add(div(x, 2), 1)
            let i := 2
            for {} lt(i, halfX) {} {
                if iszero(mod(x, i)) {
                    p := 0
                    break
                }

                i := add(i, 1)
            }
        }
    }
}
