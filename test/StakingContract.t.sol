// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {StakingContract} from "src/StakingContract.sol";
import {NFT721} from "src/NFT721.sol";
import {RewardToken} from "src/RewardToken.sol";

contract StakingContractTest is Test {
    StakingContract stakingContract;
    NFT721 nftContract;
    RewardToken rewardToken;

    address public address1 = address(0x10);

    address public address2 = address(0x22);

    function setUp() external {
        // prepare the stake nft contract,rewardERC20 Token  for staingContract
        nftContract = new NFT721(0x5a62e056db9887c17d8ded5d939c167f0aab07ac728c32753b86ca0ffa0b3362);
        rewardToken = new RewardToken(); // should adjust

        stakingContract = new StakingContract(address(nftContract),address(rewardToken));

        // address1 mint one
        vm.deal(address1, 0.1 ether);
        vm.prank(address1);
        nftContract.mintNft{value: 0.1 ether}();
        console.log("address,tokenID", 0, nftContract.ownerOf(0));
    }

    // test nft owner change
    function test_Stake() external {
        vm.startPrank(address1);

        nftContract.safeTransferFrom(address1, address(stakingContract), 0);

        assertEq(nftContract.ownerOf(0), address(stakingContract));
        console.log(nftContract.ownerOf(0), address(stakingContract));
        vm.stopPrank();
    }

    // test only the corrospending deposit can withdraw
    //  quesiton same transaciton ???
    function test_WithdrawNFT() external {
        vm.startPrank(address1);

        nftContract.safeTransferFrom(address1, address(stakingContract), 0);

        assertEq(nftContract.ownerOf(0), address(stakingContract));
        console.log(nftContract.ownerOf(0), address(stakingContract));

        stakingContract.withdrawNFT(0);
        assertEq(nftContract.ownerOf(0), address1);
        vm.stopPrank();
    }

    // test withdraw rewards, should caclucate the rewards.
    function test_withdrawRewardWhileStakingNFT() external {
        console.log("block.timestamp", block.timestamp);
        vm.startPrank(address1);

        nftContract.safeTransferFrom(address1, address(stakingContract), 0);

        // after 1 days
        console.log("balance", rewardToken.balanceOf(address1));
        vm.warp(block.timestamp + 1 days);
        stakingContract.withdrawRewards(0);
        console.log("balance", rewardToken.balanceOf(address1));
        vm.stopPrank();
        assertEq(10 * 10 ** 18, rewardToken.balanceOf(address1));
    }

    function test_withdrawRewardsAfterWithDrawNFT() external {
        // stake NFT
        vm.startPrank(address1);

        nftContract.safeTransferFrom(address1, address(stakingContract), 0);
        vm.warp(block.timestamp + 1 days);

        // withdraw NFT after 1 day
        stakingContract.withdrawNFT(0);

        // withdrawRewards
        console.log("balance", rewardToken.balanceOf(address1));
        stakingContract.withdrawRewards(0);
        console.log("balance", rewardToken.balanceOf(address1));
        vm.stopPrank();
        assertEq(10 * 10 ** 18, rewardToken.balanceOf(address1));
    }

    // test  history rewards and staking rewards
    function test_withdrawRewardsAfteSecondStake() external {
        // stake NFT
        vm.startPrank(address1);
        nftContract.safeTransferFrom(address1, address(stakingContract), 0);

        // withdraw NFT after 1 day, 10ERC Token rewards.
        vm.warp(block.timestamp + 1 days);
        stakingContract.withdrawNFT(0);

        // stake NFT again and staking time acheived 0.5 days.  5ERC Token rewards.
        vm.warp(block.timestamp + 1 days);
        nftContract.safeTransferFrom(address1, address(stakingContract), 0);

        vm.warp(block.timestamp + 0.5 days);
        // withdrawRewards
        stakingContract.withdrawRewards(0);
        vm.stopPrank();
        assertEq((10 + 5) * 10 ** 18, rewardToken.balanceOf(address1));
    }

    function test_RevertWhenNoRewardsByWrongAddress() external {
        console.log("block.timestamp", block.timestamp);
        vm.startPrank(address1);
        vm.expectRevert();
        stakingContract.withdrawRewards(0);
        vm.stopPrank();
    }

    function test_RevertWhenNoRewardsAfterWithdraw() external {
        console.log("block.timestamp", block.timestamp);
        vm.startPrank(address1);
        nftContract.safeTransferFrom(address1, address(stakingContract), 0);

        vm.warp(block.timestamp + 1 days);
        stakingContract.withdrawRewards(0);

        // second withdrawRewards
        vm.expectRevert();
        stakingContract.withdrawRewards(0);

        vm.stopPrank();
    }
}

/**
 * todo
 * 1: onERC721Received, should check the caller
 * 2. calculation the erc20 rewards
 * 3. consider the timestampe cascade change todo
 *      1. test_withdrawERC20Token should update the ERC20 rewards
 * 4. the data structure desgin should adjust?? todo consider
 * 5. Ownable2Step and safetransfer today doing
 * 6. contract @dev explain
 * 7. rayality explain
 */
