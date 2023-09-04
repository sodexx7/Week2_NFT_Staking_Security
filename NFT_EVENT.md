
Revisit the solidity events tutorial. How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable? Explain how you would accomplish this if you were creating an NFT marketplace



 ##  1. How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable?

OpenSea should have a database that stores all the NFT addresses. Perhaps it gathers all the info by monitoring the block or etherscan.info or other third-party services like Morails.

It is based on the NFT smart contract addresses and one owner address. When one NFT mints or transfers. The listening event involved with the transfer events on their service will be triggered.

The demo code is below: tokenAddress is the NFT address, and filterAddress is the owner address. So when the event was triggered, the owner's NFT info can be rendered.

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


## 2. Explain how you would accomplish this if you were creating an NFT marketplace

The NFT marketplace's main features, in my understanding as follows:
1. List all NFT info, which the NFT address or the owner can search.
2. Should update the related NFT info while an NFT was transferred or created.
3. Display the  details of an NFT
4. Buy and sell NFT

For this question, I think the point is how to know the owner's latest NFT info. 

1. One solution is maintaining a centralized service that should store all the NFT addresses and listen to the NFT transfer event just like Opensea. Each time the listening event was triggered, the related NFT info should be updated.

2. But this solution needs more resources, such as cloud service, databases, IT operators. Some other services, and maybe some of them are decentralized services that can listen to the events so we can  
integrate these services. Like subgraph, Moralis. However, reliability and consistency should also be considered in some circumstances. 







