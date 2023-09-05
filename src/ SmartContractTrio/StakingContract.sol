// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {RewardToken} from "./RewardToken.sol";

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import {NFT721} from "./NFT721.sol";

/**
 * @title support ERC721 NFT to stake,and rewarding tERC20 Token
 * @author Tony
 * @notice
 * @dev User can stake an NFT under the NFT721 contract and get the corrospending RewardToken, which based on the staking period.
 * User can withdraw an NFT anytime, and can withdraw all amount of RewardToken when withdrawRewards .
 *
 * If the user withdraws an NFT, the reward calculation will stop,
 * and the unWithdrawnRewards will be recorded, which will be clear when the user withdrawRewards the next time.
 *
 */
contract StakingContract is IERC721Receiver {
    // staking nft address
    NFT721 immutable _nft1;

    // reward ERC20 Token
    RewardToken immutable _rewardToken;

    // every 27 sec, can get the 3125000000000000 ERC20 token，so that 24 hours can get 10 ERC20 token
    uint256 constant REWARD_EACH_27_SECONDS = 3_125_000_000_000_000;

    /**
     * @dev mapping a staker address to a nft's cumulative reward  while this nft was been withdrawed.
     * only apply when nft was withdrawed, but the reward was not witdraw
     */
    mapping(address => mapping(uint256 => uint256)) private _unWithdrawnRewardsEachNFT;

    // mapping an nft to originalOwner
    mapping(uint256 => address) private _originalOwner;

    // mapping an nft to its last timestampe of staking
    mapping(uint256 => uint256) private _stakeLastBeginTime;

    event Stake(address indexed staker, uint256 indexed tokenId, uint256 timestampe);

    event WithdrawNFT(address indexed staker, uint256 indexed tokenId);

    event WithdrawRewards(address indexed withdrawer, uint256 indexed tokenId, uint256 rewardAmount);

    event UpdateUnwithdrawnRewards(address indexed staker, uint256 indexed tokenId, uint256 CumuRewards);

    constructor(address nft1, address rewardToken) {
        _nft1 = NFT721(nft1);
        _rewardToken = RewardToken(rewardToken);
    }

    function onERC721Received(
        address,
        /**
         * operator
         */
        address from,
        uint256 tokenId,
        bytes calldata
    )
        /**
         * data
         */
        external
        returns (bytes4)
    {
        // Only the _nft1 can call this funciton, security consideration
        require(msg.sender == address(_nft1), "illeage call");

        _stakeLastBeginTime[tokenId] = block.timestamp;

        _originalOwner[tokenId] = from;

        emit Stake(from, tokenId, block.timestamp);

        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * @dev staker withdraw an NFT, only the nft owner can withdraw the NFT,
     * After withdraw NFT,should stop the rewarding calculation, which should be add to the unwithdrawnRewards.
     *
     * for prevent re-entrance: use Checks-Effects-Interactions Pattern
     *
     * @param tokenId staked NFT
     */
    function withdrawNFT(uint256 tokenId) external {
        require(_originalOwner[tokenId] == msg.sender, "Not original owner");

        delete _originalOwner[tokenId];

        _nft1.safeTransferFrom(address(this), msg.sender, tokenId);

        emit WithdrawNFT(msg.sender, tokenId);

        // if there are new generated rewards, should put that into the unwithdrawnRewards.
        uint256 rewardTokenAmount = calculateRewards(tokenId);
        // stop the rewarding calculation
        delete _stakeLastBeginTime[tokenId];

        if (rewardTokenAmount > 0) {
            uint256 unwithdrawnCumuRewards = _unWithdrawnRewardsEachNFT[msg.sender][tokenId] + rewardTokenAmount;
            _unWithdrawnRewardsEachNFT[msg.sender][tokenId] = unwithdrawnCumuRewards;
            emit UpdateUnwithdrawnRewards(msg.sender, tokenId, unwithdrawnCumuRewards);
        }
    }

    /**
     * @dev Only the caller has staked NFT or has the cumulative unwithdrawn awards, can call this funciton
     *
     * Withdraw the rewards, two considerations:
     * 1:if the nft was staked,the withdrawAmount includes the staking rewards and the cumulative unwithdrawn awards(if has unwithdrawn awards),then should calculate the
     * rewards in new time.
     * 2: if the nft was not staked, directly check whether the staker has cumulative unwithdrawn awards.
     *
     * each withdraw, should withdraw all rewards including the history rewards.
     *
     * @param tokenId staked NFT
     */
    function withdrawRewards(uint256 tokenId) external {
        // cumulative unwithdrawn awards
        uint256 cumuReward = _unWithdrawnRewardsEachNFT[msg.sender][tokenId];
        require(_originalOwner[tokenId] == msg.sender || cumuReward > 0, "No reward can withdraw");

        _unWithdrawnRewardsEachNFT[msg.sender][tokenId] = 0;

        // nft was staked, rewards staking rewards and the cumulative unwithdrawn awards
        if (_originalOwner[tokenId] == msg.sender) {
            uint256 rewardTokenAmount = calculateRewards(tokenId);
            require(rewardTokenAmount + cumuReward > 0, "No reward for now");
            _rewardToken.mint(msg.sender, rewardTokenAmount + cumuReward);
            _stakeLastBeginTime[tokenId] = block.timestamp;
            emit WithdrawRewards(msg.sender, tokenId, rewardTokenAmount + cumuReward);
        } else {
            // nft has been withdrawed,check the cumulative unwithdrawn awards
            require(cumuReward > 0, "No history reward can withdraw");
            _rewardToken.mint(msg.sender, cumuReward);
            emit WithdrawRewards(msg.sender, tokenId, cumuReward);
        }
    }

    /**
     * @dev calculate the rewards during the nft staking
     * every 27 sec, can get the 3125000000000000 ERC20 token. so that 24 hours can get 10 ERC20 token, whose decimal is 10**18.
     *
     * how to get the 27 seconds?
     *  10 ERC20 = 10*10**18                /          24 hours =  60 * 60 * 24
     *  10*10**18 /60 * 60 * 24 = 100000000000000000/864,and the Greatest Common Factor for the two numbers are 32.
     *  So,get the below nunmber:
     * (100000000000000000/32) / (864/32) = 3125000000000000/27
     *
     *  It's convence to calcuate the rewards, which can get the 10ERC20 Tokens every 24 hours, and no lossing of precision.
     *
     * @param tokenId staked NFT
     */
    function calculateRewards(uint256 tokenId) public view returns (uint256 rewardToken) {
        require(_stakeLastBeginTime[tokenId] > 0, "this nft not staking");
        return (block.timestamp - _stakeLastBeginTime[tokenId]) / 27 * REWARD_EACH_27_SECONDS;
    }
}
