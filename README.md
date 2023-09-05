
## Week 2: Nonfungible Token Extensions, Staking, and Security


### Files Info
1. [ERC777_ERC1363.md](ERC721A.md)
2. [Wrapped_NFT_Pattern](Wrapped_NFT_Pattern.md)
3. [NFT_EVENT.md](NFT_EVENT.md)   
4. [SmartContractTrio](<src/ SmartContractTrio>)

    4.1 [MerkleTree](script/MerkleTree)

5. [NFTEnumerableContracts](src/NFTEnumerableContracts)
6. [CTFs](src/CTFs)

    6.1 [Overmint1Attacker](test/CTFs.Attacker.t/Overmint1Attacker.sol)
    
    6.2 [Overmint2Attacker](test/CTFs.Attacker.t/Overmint2Attacker.sol)
7. [gas_profile.png](gas_profile.png)
8. [forge_coverage](forge_coverage.png)

```
src
├──  SmartContractTrio
│   ├── NFT721.sol
│   ├── RewardToken.sol
│   └── StakingContract.sol
├── CTFs
│   ├── Overmint1.sol
│   ├── Overmint2.sol
│   └── test.sol
└── NFTEnumerableContracts
    ├── NFTCollection.sol
    └── NFTGame.sol

test
├──  SmartContractTrio.t
│   ├── NFT721.t.sol
│   └── StakingContract.t.sol
├── CTFs.Attacker.t
│   ├── Overmint1Attacker.sol
│   └── Overmint2Attacker.sol
└── NFTEnumerableContracts.t
    ├── NFTCollection.t.sol
    └── NFTGame.t.sol

script/MerkleTree/
├── createMerkleProof.js
├── createMerkleTree.js
└── tree.json


```


#### todo
0. pehaps not take full potential of the gas optimation for  NFTGame contract 
1. interface function check
2. event test 
3. vm.expectRevert add msg
4. foundry more test feature usages
    https://www.rareskills.io/post/foundry-testing-solidity
    https://www.rareskills.io/post/foundry-forge-coverage
    4.1 forge_coverage should add more
    4.2 Mutation Test
    4.3 
5. more checklist: 
    1. Static analysis with solhint, slither, and mythX

#### reference: 
https://betterprogramming.pub/the-ultimate-100-point-checklist-before-sending-your-smart-contract-for-audit-af9a5b5d95d0  checking
    