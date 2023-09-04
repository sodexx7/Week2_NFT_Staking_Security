// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {NFTCollection} from "src/NFTEnumerableContracts/NFTCollection.sol";

/// @title
contract NFTGame {
    NFTCollection private _nFTCollection ;

    constructor(address nFTCollection){
        _nFTCollection = NFTCollection(nFTCollection);
    }

    function calculateNumsOfPrimeNFT(address owner) external view returns (uint256) {
        uint256 amounts = _nFTCollection.balanceOf(owner);
        uint256 totalPrimeCounts;
        for (uint256 i = 0; i < amounts; i++) {
            uint256 tokenId = _nFTCollection.tokenOfOwnerByIndex(owner, i);
            if(isPrime(tokenId) && tokenId != 1){
                ++totalPrimeCounts;
            }
        }
        return totalPrimeCounts;
    }

    // dig more ??
    function isPrime(uint256 x) public pure returns (bool p) {
        p = true;
        assembly {
            let halfX := add(div(x, 2), 1)
            let i := 2
            for {

            } lt(i, halfX) {

            } {
                if iszero(mod(x, i)) {
                    p := 0
                    break
                }

                i := add(i, 1)
            }
        }
    }
}
