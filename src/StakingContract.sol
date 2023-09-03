// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {RewardToken} from "./RewardToken.sol";

import {IERC721Receiver} from "@openzeppelin/contracts//token/ERC721/IERC721Receiver.sol";

import {NFT721} from "./NFT721.sol";

import "forge-std/console.sol";

/// @title
/**
 * @title support ERC721 NFT to stake, NFT1 NFT
 * @author
 * @notice
 * @
 */
contract StakingContract is IERC721Receiver {
    // struct StakeInfo {
    //     uint256 tokenId;
    //     uint256 lastTimeStampe;
    // }

    event Stake(address indexed staker, uint256 indexed tokenId, uint256 timestampe);

    // time storage the nft sender, the calcuation of erc20
    // 10 ERC20 PER 24 HOURS

    // operations
    // staker, stake, withdraw
    // stake timestampe
    // one address maybe stake more nfts

    // how to confirm one nft?
    // nft adress and tokeID

    mapping(uint256 => address) _tokenIdAddress;

    // tokenID->last deposit timestampe
    mapping(uint256 => uint256) _toekIdTimeStampe;

    // should adjust?
    uint256 constant REWARD_PER_27_SECONDS = 3_125_000_000_000_000;

    NFT721 _nft1;
    RewardToken _rewardToken;

    // todo event summary

    // stake: transfer the nft to this address?

    constructor(address nft1, address rewardToken) {
        _nft1 = NFT721(nft1);
        _rewardToken = RewardToken(rewardToken);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4){
        // require(from == address(_nft1),"illegal call");
        _toekIdTimeStampe[tokenId] = block.timestamp;// should adjust.

        return IERC721Receiver.onERC721Received.selector;
    }

    function stake(uint256 tokenId) public {
        // todo tokeID owner check?
        // check tokeId whether or not stake?
        _nft1.safeTransferFrom(msg.sender, address(this), tokenId);

        // _staker_info[msg.sender] = StakeInfo(tokenId, block.timestamp);
        _toekIdTimeStampe[tokenId] = block.timestamp;

        _tokenIdAddress[tokenId] = msg.sender;

        emit Stake(msg.sender, tokenId, block.timestamp);

        // // this function perhaps has some problems ???
        // _rewardToken.mint(msg.sender, 20 * 10 ** _rewardToken.decimals());
    }

    // // calcaute the rewards
    // function calculateReward(address staker,address staker,uint256 tokenId) internal returns (uint256 ) {
    //     // Users can send their NFTs and withdraw 10 ERC20 tokens every 24 hours

    //     // 10 ERC20 / 24 hours (60 * 60 * 24;)
    //     //  5 ERC20 /12 hours
    //     //  1 ERC20 / 2.4hour

    //     // 10 ERC20 / 24 hours
    //     // 10*10**18/86400
    //     // greatest common multiple(3200.0)
    //     // 3125000000000000(0.003125*10**18) / 27sec
    //     // every 27 sec, can get the 3125000000000000 ERC20 token.

    //     (block.timestamp-_toekIdTimeStampe[tokenId])%27*REWARD_PER_27_SECONDS;

    // }

    // withdraw 10 ERC20 tokens every 24 hours
    // check only the staker can withdraw
    function withdrawRewards(uint256 tokenId) public {
        console.log("block.timestamp",block.timestamp);
        uint256 rewardsNum = (block.timestamp - _toekIdTimeStampe[tokenId]) / 27 * REWARD_PER_27_SECONDS;
        console.log("rewardsNum",rewardsNum);
        _rewardToken.mint(msg.sender, rewardsNum);
    }

    function withdrawNFT(uint256 tokenId) public {
        // check the safeTransferFrom is appropriate??
        require(_tokenIdAddress[tokenId] == msg.sender, "Can't withdraw this NFT");

        _nft1.safeTransferFrom(address(this), msg.sender, tokenId);

        delete _tokenIdAddress[tokenId];

        // update the tokenID

        // if don't withdraw the reward, directly withdraw the NFT how to deal with the situation?
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
