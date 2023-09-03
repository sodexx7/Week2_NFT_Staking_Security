// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {
    constructor() ERC20("RewardToken", "RT") {}

    function mint(address account, uint256 amount) external virtual {
        super._mint(account, amount);
    }
}
