// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {NFT721} from "src/SmartContractTrio/NFT721.sol";

/**
 * @dev
 * Test points
 * 1: TotalSupply = 20
 * 2: Show royalty info, test_RoyaltyInfo
 * 3: Address in superlist can mint nft at a discount, and can't mint again when the same address has mint
 * 4: Only owner can withdraw this contract's balance. testOwnerWithdrawBalance
 */
contract NFT721Test is Test {
    NFT721 nftContract;

    address public address1 = address(0x10);

    address public address2 = address(0x22);

    address public owner = address(0x88);

    function setUp() external {
        vm.prank(owner);
        nftContract = new NFT721(0x5a62e056db9887c17d8ded5d939c167f0aab07ac728c32753b86ca0ffa0b3362);
    }

    function test_RevertWhenBeyondMaxSupply() external {
        vm.deal(address2, 100 ether);
        vm.startPrank(address2);

        uint8 counts;
        while (counts < 20) {
            nftContract.mintNft{value: 0.1 ether}();
            counts++;
        }

        vm.expectRevert();
        nftContract.mintNft{value: 0.1 ether}();

        vm.stopPrank();
    }

    function testMintByMerkleTree() external {
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0x8138140fea4d27ef447a72f4fcbc1ebb518cca612ea0d392b695ead7f8c99ae6;
        proof[1] = 0xc0583ede9ecfa7d0d4523cfb136f87e9aa9637d0918943863c3e9daa5e52d9b7;
        proof[2] = 0x57012ddd6abe4782cf2c994aee913e286c9135a96a27d3e746a89dccc80acf35;
        uint256 index = 9;
        vm.deal(address1, 0.01 ether);

        assertEq(nftContract.balanceOf(address1), 0);
        vm.startPrank(address1);
        nftContract.mintNftByProof{value: 0.01 ether}(proof, index);
        assertEq(nftContract.balanceOf(address1), 1);
        vm.stopPrank();
    }

    function testMint_RevertWhenNotExistByByMerkleTree() external {
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0x8138140fea4d27ef447a72f4fcbc1ebb518cca612ea0d392b695ead7f8c99ae6;
        proof[1] = 0xc0583ede9ecfa7d0d4523cfb136f87e9aa9637d0918943863c3e9daa5e52d9b7;
        proof[2] = 0x57012ddd6abe4782cf2c994aee913e286c9135a96a27d3e746a89dccc80acf35;
        uint256 index = 9;
        vm.deal(address2, 0.01 ether);

        vm.startPrank(address2);
        vm.expectRevert("Invalid proof");
        nftContract.mintNftByProof{value: 0.01 ether}(proof, index);
        vm.stopPrank();
    }

    function testMint_RevertWhenAlreadyMintByByMerkleTree() external {
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0x8138140fea4d27ef447a72f4fcbc1ebb518cca612ea0d392b695ead7f8c99ae6;
        proof[1] = 0xc0583ede9ecfa7d0d4523cfb136f87e9aa9637d0918943863c3e9daa5e52d9b7;
        proof[2] = 0x57012ddd6abe4782cf2c994aee913e286c9135a96a27d3e746a89dccc80acf35;
        uint256 index = 9;
        vm.deal(address1, 1 ether);

        assertEq(nftContract.balanceOf(address1), 0);
        vm.startPrank(address1);
        nftContract.mintNftByProof{value: 0.01 ether}(proof, index);
        assertEq(nftContract.balanceOf(address1), 1);

        // second mint
        vm.expectRevert();
        nftContract.mintNftByProof{value: 0.01 ether}(proof, index);
        vm.stopPrank();
    }

    function testMint_RevertWhenFeeNotEnougFeehByByMerkleTree() external {
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0x8138140fea4d27ef447a72f4fcbc1ebb518cca612ea0d392b695ead7f8c99ae6;
        proof[1] = 0xc0583ede9ecfa7d0d4523cfb136f87e9aa9637d0918943863c3e9daa5e52d9b7;
        proof[2] = 0x57012ddd6abe4782cf2c994aee913e286c9135a96a27d3e746a89dccc80acf35;
        uint256 index = 9;
        vm.deal(address1, 0.01 ether);

        vm.startPrank(address1);
        vm.expectRevert();
        nftContract.mintNftByProof{value: 0.001 ether}(proof, index);
        vm.stopPrank();
    }

    function testNormalMint() external {
        assertEq(nftContract.balanceOf(address2), 0);
        vm.deal(address2, 0.1 ether);
        vm.prank(address2);

        nftContract.mintNft{value: 0.1 ether}();

        assertEq(nftContract.balanceOf(address2), 1);
    }

    function testNormalMintRevert_RevetWhenFeeNotEnough() external {
        vm.deal(address2, 0.1 ether);
        vm.prank(address2);
        vm.expectRevert();
        nftContract.mintNft{value: 0.01 ether}();
    }

    function testOwnerWithdrawBalance() external {
        uint256 beforeMintBalance = address(owner).balance;

        // two address mint NFT. totoal receive 0.11 ether
        vm.deal(address2, 0.1 ether);
        vm.prank(address2);
        nftContract.mintNft{value: 0.1 ether}();

        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0x8138140fea4d27ef447a72f4fcbc1ebb518cca612ea0d392b695ead7f8c99ae6;
        proof[1] = 0xc0583ede9ecfa7d0d4523cfb136f87e9aa9637d0918943863c3e9daa5e52d9b7;
        proof[2] = 0x57012ddd6abe4782cf2c994aee913e286c9135a96a27d3e746a89dccc80acf35;
        uint256 index = 9;
        vm.deal(address1, 0.01 ether);
        vm.startPrank(address1);
        nftContract.mintNftByProof{value: 0.01 ether}(proof, index);
        vm.stopPrank();

        // owner withdraw balance should equal 0.11 ether
        vm.prank(owner);
        nftContract.widthDrawBalance();
        uint256 afterMintBalance = address(owner).balance;

        assertEq(afterMintBalance - beforeMintBalance, 0.11 ether);
    }

    // current feature: the owner will receive a reward rate of 2.5% of any NFT.
    // but when and where  the owner will receive, not implemented, just show the royalty info
    function test_RoyaltyInfo() external {
        // address1 mint a nft
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0x8138140fea4d27ef447a72f4fcbc1ebb518cca612ea0d392b695ead7f8c99ae6;
        proof[1] = 0xc0583ede9ecfa7d0d4523cfb136f87e9aa9637d0918943863c3e9daa5e52d9b7;
        proof[2] = 0x57012ddd6abe4782cf2c994aee913e286c9135a96a27d3e746a89dccc80acf35;
        uint256 index = 9;
        vm.deal(address1, 0.01 ether);
        vm.startPrank(address1);
        nftContract.mintNftByProof{value: 0.01 ether}(proof, index);
        vm.stopPrank();

        // show the nft royalty info
        (address receiver, uint256 royaltyAmount) = nftContract.royaltyInfo(0, 100 ether);
        assertEq(receiver, owner);
        assertEq(royaltyAmount, 2.5 ether);

        (receiver, royaltyAmount) = nftContract.royaltyInfo(0, 1 ether);
        assertEq(receiver, owner);
        assertEq(royaltyAmount, 0.025 ether);
    }
}
