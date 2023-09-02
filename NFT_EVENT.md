
Revisit the solidity events tutorial. How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable? Explain how you would accomplish this if you were creating an NFT marketplace

1)by the owner?? OpenSea NFT
2) 

1. How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable?


    OpenSea should have a database that store all the NFT address, perhaps get the info by monitoring the block or etherscan.info or other third-party services like Morails.
Just based on the NFT smart contract address, and one owner address. Each time when one NFT mint or transfer, just listening the transfer events.
tokenAddress is the NFT address, filterAddress is the owner address. So when the evet was triggered, then owner's NFT info can rendered.

``` solidity
const ethers = require('ethers');

const tokenAddress = '0x...';

const filterAddress = '0x...';

const abi = [
  "event Transfer(address indexed from, address indexed to, uint256 value)"
];

const tokenContract = new ethers.Contract(tokenAddress, tokenAbi, provider);

// this line filters for Approvals for a particular address.
const filter = tokenContract.filters.Transfer(filterAddress, null, null);

tokenContract.queryFilter(filter).then((events) => {
  console.log(events);
});

```


Explain how you would accomplish this if you were creating an NFT marketplace

The main features in my understanding as blew:
1: can list all NFT info, can be search by the NFT address or the owner.
2: should updated the related NFT info while a NFT was transferred or created.
3. display the  details of a NFT
4. Buy and sell NFT

For this quesiton, I think the points is how to know the owner's latest NFT info?
The opensea use the centralized service listen all the related NFT into, and update NFT info with the owner info.
For this implementation, shoud maintain a centralized service listening all related NFT infos. and can use this funcoiton
to retreat the info more 
```
fromBlock and toBlock query parameters are added
```





1)NFT address database

2)history NFT info
2)latest NFT info
    main feature: query NFT info by the tokeID,owner, contract address









