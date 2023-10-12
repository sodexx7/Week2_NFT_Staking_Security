// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {StakingContract} from "src/SmartContractTrio/StakingContract.sol";
import {NFT721} from "src/SmartContractTrio/NFT721.sol";
import {RewardToken} from "src/SmartContractTrio/RewardToken.sol";

/**
 * @dev
 * test points:
 * 1: basic operation: stake NFT,withdraw NFT, withdrawReward during the staking or the nft has been withdrawed
 * 2: stake NFT. directly transfer NFT to the stakingContract
 * 3: User can withdraw an NFT anytime
 * 4. Withdraw RewardToken in different circumstance, NFT is staking, NFT has been withdrawed
 * 5. Calculation the erc20 rewards
 * 6. ownership transfer。 transfer the ownership from  rewardToken to stakingContract
 */
contract StakingContractTest is Test {
    StakingContract stakingContract;
    NFT721 nftContract;
    RewardToken rewardToken;

    address public address1 = address(0x10);

    address public address2 = address(0x22);

    uint256 mintTokenId = 1;

    function setUp() external {
        // prepare the stake nft contract,rewardERC20 Token  for staingContract
        nftContract = new NFT721(0x5a62e056db9887c17d8ded5d939c167f0aab07ac728c32753b86ca0ffa0b3362);
        rewardToken = new RewardToken(); // should adjust

        stakingContract = new StakingContract(address(nftContract),address(rewardToken));

        // stakingContract will control the rewardToken(Ownable2Step)
        rewardToken.transferOwnership(address(stakingContract));
        vm.prank(address(stakingContract));
        rewardToken.acceptOwnership();

        // address1 mint one
        vm.deal(address1, 0.1 ether);
        vm.prank(address1);
        nftContract.mintNft{value: 0.1 ether}();
        console.log("address,tokenID", address1, mintTokenId);
    }

    // test nft owner change
    function test_Stake() external {
        vm.startPrank(address1);

        nftContract.safeTransferFrom(address1, address(stakingContract), mintTokenId);

        assertEq(nftContract.ownerOf(mintTokenId), address(stakingContract));
        console.log(nftContract.ownerOf(mintTokenId), address(stakingContract));
        vm.stopPrank();
    }

    // test only the corrospending deposit can withdraw
    //  quesiton same transaciton ???
    function test_WithdrawNFT() external {
        vm.startPrank(address1);

        nftContract.safeTransferFrom(address1, address(stakingContract), mintTokenId);

        assertEq(nftContract.ownerOf(mintTokenId), address(stakingContract));
        console.log(nftContract.ownerOf(mintTokenId), address(stakingContract));

        stakingContract.withdrawNFT(mintTokenId);
        assertEq(nftContract.ownerOf(mintTokenId), address1);
        vm.stopPrank();
    }

    // test withdraw rewards, should caclucate the rewards.
    function test_withdrawRewardWhileStakingNFT() external {
        console.log("block.timestamp", block.timestamp);
        vm.startPrank(address1);

        nftContract.safeTransferFrom(address1, address(stakingContract), mintTokenId);

        // after 1 days
        console.log("balance", rewardToken.balanceOf(address1));
        vm.warp(block.timestamp + 1 days);
        stakingContract.withdrawRewards(mintTokenId);
        console.log("balance", rewardToken.balanceOf(address1));
        vm.stopPrank();
        assertEq(10 * 10 ** 18, rewardToken.balanceOf(address1));
    }

    function test_withdrawRewardsAfterWithDrawNFT() external {
        // stake NFT
        vm.startPrank(address1);

        nftContract.safeTransferFrom(address1, address(stakingContract), mintTokenId);
        vm.warp(block.timestamp + 1 days);

        // withdraw NFT after 1 day
        stakingContract.withdrawNFT(mintTokenId);

        // withdrawRewards
        console.log("balance", rewardToken.balanceOf(address1));
        stakingContract.withdrawRewards(mintTokenId);
        console.log("balance", rewardToken.balanceOf(address1));
        vm.stopPrank();
        assertEq(10 * 10 ** 18, rewardToken.balanceOf(address1));
    }

    // test  history rewards and staking rewards
    function test_withdrawRewardsAfteSecondStake() external {
        // stake NFT
        vm.startPrank(address1);
        nftContract.safeTransferFrom(address1, address(stakingContract), mintTokenId);

        // withdraw NFT after 1 day, 10ERC Token rewards.
        vm.warp(block.timestamp + 1 days);
        stakingContract.withdrawNFT(mintTokenId);

        // stake NFT again and staking time acheived 0.5 days.  5ERC Token rewards.
        vm.warp(block.timestamp + 1 days);
        nftContract.safeTransferFrom(address1, address(stakingContract), mintTokenId);

        vm.warp(block.timestamp + 0.5 days);
        // withdrawRewards
        stakingContract.withdrawRewards(mintTokenId);
        vm.stopPrank();
        assertEq((10 + 5) * 10 ** 18, rewardToken.balanceOf(address1));
    }

    function test_RevertWhenNoRewardsByWrongAddress() external {
        console.log("block.timestamp", block.timestamp);
        vm.startPrank(address1);
        vm.expectRevert();
        stakingContract.withdrawRewards(mintTokenId);
        vm.stopPrank();
    }

    function test_RevertWhenNoRewardsAfterWithdraw() external {
        console.log("block.timestamp", block.timestamp);
        vm.startPrank(address1);
        nftContract.safeTransferFrom(address1, address(stakingContract), mintTokenId);

        vm.warp(block.timestamp + 1 days);
        stakingContract.withdrawRewards(mintTokenId);

        // second withdrawRewards
        vm.expectRevert();
        stakingContract.withdrawRewards(mintTokenId);

        vm.stopPrank();
    }
}
