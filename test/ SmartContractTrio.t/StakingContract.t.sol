// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {StakingContract} from "src/ SmartContractTrio/StakingContract.sol";
import {NFT721} from "src/ SmartContractTrio/NFT721.sol";
import {RewardToken} from "src/ SmartContractTrio/RewardToken.sol";

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
 *
 *
 * // Smart contract trio  check list
 * // 1: three contracts.
 * //      NFT with merkle tree discount(should prepare the test data and test)
 * //      ERC20 token(simple contract, just as the rewards)
 * //      staking contract(staker:stake,withdrawNFT,withdrawRewards)
 * //              1: the data structure is OK?
 * //              2: the perspective of the staking contract? ?
 * //              3: the relationships among the NFT, ERC20, staking contract, staker
 * // 2. should add some checks
 * //          staking contract(staker:stake,withdrawNFT,withdrawRewards)
 * // 1. stake tokeID , staker address check
 * // 2. reward ERC20 check?
 * // 3.  ERC 2918 royalty correct usage? how to implement? royalty specific meaning??? doing 250, to how to distribute the value
 * // 4.  the interface quesitons?  how to use the ERC 2918, the related question ERC1556
 * // 5.  security problem: stake NFTs with safetransfer/ Ownable2Step
 * // 6. explain the data structure
 * // 7. event test
 */
