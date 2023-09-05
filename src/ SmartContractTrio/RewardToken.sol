// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title This contract's token as the StakingContract's ERC20 rewards
 * @dev
 * Only the stakingContract can mint the token.
 * stakingContract should get this contract's ownership before working.
 *
 * Currently, no other consideration that limiting this token's supply
 * @author Tony
 * @notice
 */
contract RewardToken is ERC20, Ownable2Step {
    constructor() ERC20("RewardToken", "RT") {}

    function mint(address account, uint256 amount) external onlyOwner {
        super._mint(account, amount);
    }
}
