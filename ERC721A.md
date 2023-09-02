
How does ERC721A save gas? 
- [ ]  Where does it add cost? doing
- [ ]  Why shouldn’t ERC721A enumerable’s implementation be used on-chain?

1. How does ERC721A save gas?
    ERC721A implements the ERC721, which focus on saving more gas while minting many nfts  during one transaction comparing other implementations like ERC721Enumerable.

    1. directly change the amounts of minted NFT rather than increase one by one. This decrease the numbers of storage read and write operations. the storage write and read is expensive.
    2.  different data structure mataining the nft info,ERC721A save more gas while querying nft info than other mechniasm like ERC721Enumerable.

        ERC721Enumerable
        _ownedTokens
        _ownedTokensIndex
        _allTokens
        _allTokensIndex

        ERC721A
        Token IDs are minted in sequential order (e.g. 0, 1, 2, 3, ...)
        ERC721Enumerable two mapping data structure.

        todo: more cleanly explain


    1) balanceOf(owner)
    2)ownerOf()
    3)transfer(include mint)


Where does it add cost? ???
    This optimization involves some additional logic, especially when it comes to transfers
        Optimization 3??? not fully understanding.

Why shouldn’t ERC721A enumerable’s implementation be used on-chain?
    It's desgin is to query who owns the one nft effectively and convencely. the mechaniasm needs more state variables  
    such as   _ownedTokens, _ownedTokensIndex, _allTokensIndex. this involved more stroage read and write operations,



reference:
1. https://www.azuki.com/erc721a
2. https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Enumerable.sol
3. https://github.com/chiru-labs/ERC721A/blob/main/contracts/ERC721A.sol

     