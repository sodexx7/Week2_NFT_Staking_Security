// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {RewardToken} from "./RewardToken.sol";

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import {Context} from "@openzeppelin/contracts//utils/Context.sol";

import {NFT721} from "./NFT721.sol";

/// @title
/**
 * @title support ERC721 NFT to stake, NFT1 NFT
 * @author
 * @notice
 * @dev User can stake a NFT under the NFT721 and get the corrospending RewardToken, which based on the staked period.
 * User can withdraw this NFT anytime, and can withdraw the RewardToken.
 *
 * 1: NFT hasn't been withdraw
 *
 * NFT has been withdraw,but the rewards not get
 *
 * 1. how to calcuate the rewarding ERC20 token
 * 2. data structure desgin？？
 *
 *
 */
contract StakingContract is IERC721Receiver, Context {
    NFT721 _nft1;
    RewardToken _rewardToken;

    // every 27 sec, can get the 3125000000000000 ERC20 token，so that 24 hours can get 10 ERC20 token
    uint256 constant REWARD_EACH_27_SECONDS = 3_125_000_000_000_000;

    event Stake(address indexed staker, uint256 indexed tokenId, uint256 timestampe);

    event WithdrawNFT(address indexed staker, uint256 indexed tokenId);

    //  mapping a staker address to a nft's cumulative reward  while this nft was been withdrawed.
    // only using when nft was withdrawed, but the reward was not witdraw
    mapping(address => mapping(uint256 => uint256)) private _cumuRewardsEachNFT;

    // mapping a nft to the staking addresss
    mapping(uint256 => address) private _originalOwner;

    // mapping a nft to its last stake timestampe
    mapping(uint256 => uint256) private _stakeLastBeginTime;

    constructor(address nft1, address rewardToken) {
        _nft1 = NFT721(nft1);
        _rewardToken = RewardToken(rewardToken);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        _stakeLastBeginTime[tokenId] = block.timestamp;

        _originalOwner[tokenId] = from;

        emit Stake(from, tokenId, block.timestamp);

        return IERC721Receiver.onERC721Received.selector;
    }

    // /**
    //  * @dev the staker deposit one NFT, and the stakingContract begin to calcuate the staking time, which was recorded while the stakingContract received the nft,
    //  * can see the function onERC721Received.
    //  * @param tokenId  staked NFT
    //  */
    // function stake(uint256 tokenId) public {
    //     _nft1.safeTransferFrom(msg.sender, address(this), tokenId);

    // }

    /**
     * @dev staker withdraw a NFT, only the nft owner can withdraw the NFT,
     * if there are rewards that are not withdrawed, should add the rewards to the cumulative rewards
     * @param tokenId staked NFT
     * TODO the execute order has some problems?
     */
    function withdrawNFT(uint256 tokenId) public {
        require(_originalOwner[tokenId] == msg.sender, "Not original owner");

        _nft1.safeTransferFrom(address(this), msg.sender, tokenId);

        emit WithdrawNFT(msg.sender, tokenId);

        // calculate whether or not has rewards?
        // if has, update the rewards
        uint256 rewardTokenAmount = calculateRewards(tokenId);
        if (rewardTokenAmount > 0) {
            _cumuRewardsEachNFT[msg.sender][tokenId] = _cumuRewardsEachNFT[msg.sender][tokenId] + rewardTokenAmount;
        }

        delete _originalOwner[tokenId];
        delete _stakeLastBeginTime[tokenId];
    }

    /**
     * @dev Withdraw the rewards, two considerations:
     * 1:if the nft is staked,the withdrawAmount includs the staking rewards and the history rewards(if there are reward not withdraw),and should update the beginning
     * stake time
     * 2: if the nft is not staked, directly check whether the staker has culimateReward and withdraw.
     * each withdraw, should withdraw all rewards including the history rewards.
     * @param tokenId staked NFT
     * // TODO , complexity???
     */
    function withdrawRewards(uint256 tokenId) public {
        // history rewards, if have should withdraw
        uint256 cumuReward = _cumuRewardsEachNFT[msg.sender][tokenId];
        require(_originalOwner[tokenId] == msg.sender || cumuReward > 0, "No reward can withdraw");

        // check nft is staked
        if (_originalOwner[tokenId] == msg.sender) {
            uint256 rewardTokenAmount = calculateRewards(tokenId);
            require(rewardTokenAmount + cumuReward > 0, "No reward for now");
            _rewardToken.mint(msg.sender, rewardTokenAmount + cumuReward);
            _stakeLastBeginTime[tokenId] = block.timestamp;
        } else {
            // nft has been withdrawed,check the address with the tokenID have enough reward can withdraw
            require(cumuReward > 0, "No history reward can withdraw");
            _rewardToken.mint(msg.sender, cumuReward);
        }

        _cumuRewardsEachNFT[msg.sender][tokenId] = 0;
    }

    /**
     * @dev calculate the rewards during the nft staking
     * every 27 sec, can get the 3125000000000000 ERC20 token. so that 24 hours can get 10 ERC20 token, whose decimal is 10**18.
     *
     * how to get the 27 seconds?
     *  10 ERC20 = 10*10**18 / 24 hours =  60 * 60 * 24
     *  10*10**18/60 * 60 * 24 = 100000000000000000/864 the Greatest Common Factor for the two numbers are 32.
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

//  staker
// 1.stake NFT
// 2.staker withdraw NFT
// 3. staker can withdraw ERC20 rewards. if withdraw the NFT , the reward clear. ???
// 1. have withdraw the nft
// 2. don't withdraw the nft
// update the tokeID timestampe

// 4.

// 2. data structure ???
//      _staker_info  tokeId => timeStampeInfo
//      stake          staker(address) => tokeId

// Smart contract trio  check list
// 1: three contracts.
//      NFT with merkle tree discount(should prepare the test data and test)
//      ERC20 token(simple contract, just as the rewards)
//      staking contract(staker:stake,withdrawNFT,withdrawRewards)
//              1: the data structure is OK?
//              2: the perspective of the staking contract? ?
//              3: the relationships among the NFT, ERC20, staking contract, staker
// 2. should add some checks
//          staking contract(staker:stake,withdrawNFT,withdrawRewards)
// 1. stake tokeID , staker address check
// 2. reward ERC20 check?
// 3.  ERC 2918 royalty correct usage? how to implement? royalty specific meaning??? doing 250, to how to distribute the value
// 4.  the interface quesitons?  how to use the ERC 2918, the related question ERC1556
// 5.  security problem: stake NFTs with safetransfer/ Ownable2Step
// 6. explain the data structure
// 7. event test
