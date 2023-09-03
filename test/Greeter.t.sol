// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract GreeterTest is Test {
    using stdStorage for StdStorage;

    function setUp() external {}

    // VM Cheatcodes can be found in ./lib/forge-std/src/Vm.sol
    // Or at https://github.com/foundry-rs/forge-std
    function testSetGm() external view {
        // slither-disable-next-line reentrancy-events,reentrancy-benign
        uint256 test = (1 / 10) * 10 ** 18 * 250 / 10000;
        console.log(test);

        uint256 test2 = 10 ** 4 * 250 / 10000;
        console.log(test2);
    }
}
