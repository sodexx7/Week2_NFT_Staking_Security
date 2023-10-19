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

    uint256 constant REWARD_EACH_27_SECONDS = 3_125_000_000_000_000;

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

    function test_onERC721ReceivedRevert() external {
        vm.expectRevert(bytes("illeage call"));
        stakingContract.onERC721Received(msg.sender, address1, mintTokenId, "0x");
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

    function test_WithdrawNFTRevertNonOwner() external {
        vm.startPrank(address1);

        nftContract.safeTransferFrom(address1, address(stakingContract), mintTokenId);

        assertEq(nftContract.ownerOf(mintTokenId), address(stakingContract));
        console.log(nftContract.ownerOf(mintTokenId), address(stakingContract));
        vm.stopPrank();

        vm.prank(address2); //non orginal owner
        vm.expectRevert(bytes("Not original owner"));
        stakingContract.withdrawNFT(mintTokenId);
    }

    // test withdraw rewards, should caclucate the rewards.
    function test_withdrawRewardWhileStakingNFTNoCumu() external {
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

    function test_withdrawRewardWithMoreStakeOperations() external {
        console.log("block.timestamp", block.timestamp);
        vm.startPrank(address1);

        nftContract.safeTransferFrom(address1, address(stakingContract), mintTokenId);

        // after 1 days
        console.log("balance", rewardToken.balanceOf(address1));
        vm.warp(block.timestamp + 1 days);
        // WithDrawNFT but don't withdraw rewards
        stakingContract.withdrawNFT(mintTokenId);

        // after 2 days, stakeNFT again 
        vm.warp(block.timestamp + 2 days);
        nftContract.safeTransferFrom(address1, address(stakingContract), mintTokenId);


        // after new staking, withdrawRewards again, which includes staking and Cumu rewards
        vm.warp(block.timestamp + 1 days);
        stakingContract.withdrawRewards(mintTokenId);

        vm.stopPrank();
        assertEq(20 * 10 ** 18, rewardToken.balanceOf(address1));
    }

    function test_withdrawRewardWhileNoStakingHasCumu() external {
        console.log("block.timestamp", block.timestamp);
        vm.startPrank(address1);

        nftContract.safeTransferFrom(address1, address(stakingContract), mintTokenId);

        // after 1 days
        vm.warp(block.timestamp + 1 days);
        // address1 only withDrawNFT
        stakingContract.withdrawNFT(mintTokenId);
        vm.stopPrank();

        vm.prank(address1);
        stakingContract.withdrawRewards(mintTokenId);
        assertEq(10 * 10 ** 18, rewardToken.balanceOf(address1));

    }

    function test_withdrawRewarNoReward() external {
        console.log("block.timestamp", block.timestamp);
        vm.startPrank(address1);

        nftContract.safeTransferFrom(address1, address(stakingContract), mintTokenId);
        vm.expectRevert(bytes("No reward for now"));
        stakingContract.withdrawRewards(mintTokenId);
        vm.stopPrank();

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
        vm.expectRevert(bytes("No reward can withdraw"));
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
        vm.expectRevert(bytes("No reward for now"));
        stakingContract.withdrawRewards(mintTokenId);

        vm.stopPrank();
    }

    function test_CalculateRewards() external {
        console.log("block.timestamp", block.timestamp);
        uint256 beforeBlockTimeStamp = block.timestamp;
        vm.startPrank(address1);
        nftContract.safeTransferFrom(address1, address(stakingContract), mintTokenId);
        vm.stopPrank();
        vm.warp(block.timestamp + 1 days);
        uint256 rewards = stakingContract.calculateRewards(mintTokenId);

        assertEq(rewards, (block.timestamp - beforeBlockTimeStamp) / 27 * REWARD_EACH_27_SECONDS);
    }

    function test_CalculateRewardsNoStaking() external {
        uint rewards =  stakingContract.calculateRewards(mintTokenId + 1);
        assertEq(rewards,0);
    }

    function test_rewardTokenRevertNoOwner() external {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        rewardToken.mint(msg.sender, 0);

    }
}
