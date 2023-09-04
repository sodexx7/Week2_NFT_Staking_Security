// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {NFTGame} from "src/NFTEnumerableContracts/NFTGame.sol";
import {NFTCollection} from "src/NFTEnumerableContracts/NFTCollection.sol";

contract NFTGameTest is Test {
    address public address1 = address(0x10);
    NFTGame nFTGame;
    NFTCollection nFTCollection;

    function setUp() external {
        // address1 owns 20 NFTS
        nFTCollection = new NFTCollection();
        nFTGame = new NFTGame(address(nFTCollection));

        vm.startPrank(address1);
        for (uint256 i = 1; i <= 20; i++) {
            nFTCollection.safeMint();
        }
        vm.stopPrank();
    }

    function test_CalculateNumsofPrimeNFT() external {
        //  2, 3, 5, 7, 11, 13, 17 and 19.
        assertEq(nFTGame.calculateNumsOfPrimeNFT(address1), 8);
    }
}

// Todo gas optimize
