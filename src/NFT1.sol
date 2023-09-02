// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ERC20 } from "solmate/tokens/ERC20.sol";

/// @title Greeter
contract Greeter {
  string public greeting;
  address public owner;

  // CUSTOMS
  error BadGm();
  event GMEverybodyGM();

  constructor(string memory newGreeting) {
    greeting = newGreeting;
    owner = msg.sender;
  }

  function gm(string memory myGm) external returns(string memory greet) {
    if (keccak256(abi.encodePacked((myGm))) != keccak256(abi.encodePacked((greet = greeting)))) revert BadGm();
    emit GMEverybodyGM();
  }

  function setGreeting(string memory newGreeting) external {
    greeting = newGreeting;
  }
}


/**
 *  Smart contract trio: NFT with merkle tree discount, ERC20 token, staking contract
 *  1: Create an ERC721 NFT with a supply of 20.
 *  2: Include ERC 2918 royalty in your contract to have a reward rate of 2.5% for any NFT in the collection. Use the openzeppelin implementation.
 *  3: Addresses in a merkle tree can mint NFTs at a discount. Use the bitmap methodology described above. Use openzeppelin’s bitmap, don’t implement it yourself.
 */
