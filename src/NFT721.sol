// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IERC721, ERC721, ERC165, IERC165} from "@openzeppelin/contracts//token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/// @title NFT1
contract NFT721 is ERC721, ERC2981, Ownable2Step {
    // bytes32 = [byte, byte, ..., byte] <- 32 bytes
    bytes32 public immutable _merkleRoot;
    BitMaps.BitMap private _superMintList;

    // another solution <=20 decreament???
    uint8 private constant TOTAL_SUPPLY = 20;
    uint8 private _tokenCounter;

    string public constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC2981, ERC721) returns (bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(ERC2981).interfaceId
            || super.supportsInterface(interfaceId);
    }

    constructor(bytes32 merkleRoot) ERC721("NFT721", "NFT1") {
        _merkleRoot = merkleRoot;
        // set the reward rate as 2.5%, the least price should bigger than 10**4wei
        _setDefaultRoyalty(address(this), 250);
    }

    // This implementation support mint one nft per address
    function mintNftByProof(bytes32[] calldata proof, uint256 index) external payable {
        require(_tokenCounter < TOTAL_SUPPLY, "Beyond totalSupply");
        require(msg.value >= 0.01 ether, "NOT Enough ETH to mint at a discount");

        // BitMaps.sol and MerkleProof check
        // check if already claimed
        require(!BitMaps.get(_superMintList, index), "Already claimed");

        // verify proof
        _verifyProof(proof, index, msg.sender);
        //  true, add discount info, related with the ERC2981???
        // set airdrop as claimed
        BitMaps.setTo(_superMintList, index, true);

        _safeMint(msg.sender, _tokenCounter);
        _tokenCounter = _tokenCounter + 1;
    }

    function mintNft() external payable {
        require(_tokenCounter < TOTAL_SUPPLY, "Beyond totalSupply");
        require(msg.value >= 0.1 ether, "NOT Enough ETH to mint");

        _safeMint(msg.sender, _tokenCounter);
        _tokenCounter = _tokenCounter + 1;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return TOKEN_URI;
    }

    function getTokenCounter() public view returns (uint256) {
        return _tokenCounter;
    }

    function _verifyProof(bytes32[] memory proof, uint256 index, address addr) private view {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(addr, index))));
        require(MerkleProof.verify(proof, _merkleRoot, leaf), "Invalid proof");
    }
}

/**
 *  Smart contract trio: NFT with merkle tree discount, ERC20 token, staking contract
 *  1: Create an ERC721 NFT with a supply of 20.
 *      how to dealwith baseURI?
 *      totaLSupply 20? vs tokenID max value < 20?
 *      //1: why use _safeMint? orginal Mint quesiton?
 *      // 2. TODO  TOKEN_URI set
 *      3. check supportsInterface???
 *
 *
 *  2: Include ERC 2918 royalty in your contract to have a reward rate of 2.5% for any NFT in the collection. Use the openzeppelin implementation.
 *      how to understand this?
 *  3: Addresses in a merkle tree can mint NFTs at a discount. Use the bitmap methodology described above. Use openzeppelin’s bitmap, don’t implement it yourself.
 *      Addresses in a merkle tree can mint NFTs at a discount.
 *      buid the merkle tree, the flow?
 *            address,
 *            at a discount
 *            whether has mint or not?
 *    todo
 *      1: create merkle tree and verify
 *      2: prepare the corresponding test cases
 *      3: figure out two concepts: merkle tree and bitmaps
 *
 *
 *
 *  reference:
 *  https://github.com/jordanmmck/MerkleTreesBitmaps/blob/master/src/AirDropToken.sol
 */
