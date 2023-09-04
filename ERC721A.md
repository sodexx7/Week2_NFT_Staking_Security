
-   How does ERC721A save gas?
-   Where does it add cost? should make clean understanding
-   Why shouldn’t ERC721A enumerable’s implementation be used on-chain?


## 1. How does ERC721A save gas?

ERC721A implements the ERC721, which focuses on saving more gas while minting multiple NFTs during one transaction compared to other implementations like ERC721Enumerable.

1. Decreasing each token's write storage operations comparing the ERC721Enumerable. As we know, storage write operations are very expensive. 
    ERC721Enumerable maintains allToken and ownerToken info, while ERC721A uses the bit info as far as possible.


2. Update the owner's balance once rather than one by one while minting multiple NFTs.

3. Like point 2, update the owner's data once rather than one by one while minting multiple NFTs. This new method seems complex.
  

## 2. Where does it add cost?

Although ERC721A decreases the storage writing operations during minting, increasing more logic to implement the design, It's obvious that the operations
, includes mint, transfer, approve, seems to have more logic. Especially the transfer seems to have more logic, leading to more cost.

## 3. Why shouldn't ERC721A enumerable's implementation be used on-chain?

It's design is to query who owns one NFT effectively and conveniently. The mechanism needs more state variables, including allTokenID and ownerTokenInfo, which leads to more storage write operations to maintain the data structure. Actually, each transfer needs to sync all these states.
    


## reference:

1. https://www.azuki.com/erc721a
2. https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Enumerable.sol
3. https://github.com/chiru-labs/ERC721A/blob/main/contracts/ERC721A.sol

     