// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {NFTCollection} from "src/NFTEnumerableContracts/NFTCollection.sol";

contract NFTCollectionTest is Test {
    NFTCollection nFTCollection;

    address public address1 = address(0x10);

    address public address2 = address(0x22);

    address public owner = address(0x88);

    function setUp() external {
        nFTCollection = new NFTCollection();
    }

    function test_TokenIdRanges() external {
        vm.startPrank(address1);
        for (uint256 i = 1; i <= 20; i++) {
            nFTCollection.safeMint();
        }
        vm.stopPrank();

        vm.startPrank(address1);
        // address1 should own 20 NFTs
        assertEq(nFTCollection.balanceOf(address1), 20);

        // tokenId should in [1,20]
        for (uint256 i = 0; i < 20; i++) {
            assertEq(i + 1, nFTCollection.tokenByIndex(i));
        }
        vm.stopPrank();
    }

    function test_RevertWhenBeyondTokenIdRanges() external {
        vm.startPrank(address1);

        for (uint256 i = 1; i <= 20; i++) {
            nFTCollection.safeMint();
        }
        vm.expectRevert();
        nFTCollection.safeMint();
        vm.stopPrank();
    }

    function test_checkSupportsInterface() external {
        assertEq(nFTCollection.supportsInterface(0x780e9d63), true);//ERC721Enumerable
        assertEq(nFTCollection.supportsInterface(0x01ffc9a7), true);//IERC165

    }

    function test_checkSupportsInterfaceRevert() external {
        assertEq(nFTCollection.supportsInterface(0x78ae9d63), false);
    }
}
