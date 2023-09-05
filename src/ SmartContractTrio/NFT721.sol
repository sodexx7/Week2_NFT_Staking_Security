// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IERC721, ERC721} from "@openzeppelin/contracts//token/ERC721/ERC721.sol";
import {IERC2981, ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title This contract's NFT  as the staking NFT in the StakingContract
 * @dev
 * 1:This NFT MAX_SUPPLY is 20;
 * 2: Support superMint and Normal Mint, each has different payment price, This implementation is based on the merkle tree and bitmap.
 *      reference:https://github.com/jordanmmck/MerkleTreesBitmaps/blob/master/src/AirDropToken.sol
 * 3: Can show the royalty info, currently all these related rewards is bond with the contract owner;
 * 4: Only the owner can withdraw this contract's balance, which acquired by selling the NFT.
 * 5: apply Ownable2Step instead of Ownable to improve the security level, beside that disable the function renounceOwnership
 * @author  Tony
 * @notice
 */
contract NFT721 is ERC721, ERC2981, Ownable2Step {
    // check the minter belong to the uperMintList by merkle lib
    bytes32 public immutable _merkleRoot;
    // check the mint whether or not minted
    BitMaps.BitMap private _superMintList;

    uint8 private constant MAX_SUPPLY = 20;

    uint128 public totalSupply;

    // for simple show, currently ignore
    string public constant TOKEN_URI = "test url";

    constructor(bytes32 merkleRoot) ERC721("NFT721", "NFT1") {
        _merkleRoot = merkleRoot;
        // set the reward rate as 2.5%, the least price should bigger than 10**4wei
        _setDefaultRoyalty(owner(), 250);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC2981, ERC721) returns (bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC2981).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev
     * check the paymentInfo directly by the msg.value, paymentInfo was not included in the proof. If need, can put the info
     * while buidling the merkle tree.
     */
    function mintNftByProof(bytes32[] calldata proof, uint256 index) external payable {
        require(totalSupply <= MAX_SUPPLY, "Beyond totalSupply");

        // verify proof
        _verifyProof(proof, index, msg.sender);

        require(msg.value >= 0.01 ether, "NOT Enough ETH to mint at a discount");

        // check if the minter  claimed or not
        require(!BitMaps.get(_superMintList, index), "Already claimed");

        // set airdrop as claimed
        BitMaps.setTo(_superMintList, index, true);

        totalSupply = totalSupply + 1;
        _safeMint(msg.sender, totalSupply);
    }

    /**
     * @dev everyone can mint, and not limit the numers.
     * If necessary, should prevent re-entrance ??
     */
    function mintNft() external payable {
        require(totalSupply <= MAX_SUPPLY, "Beyond totalSupply");
        require(msg.value >= 0.1 ether, "NOT Enough ETH to mint");

        totalSupply = totalSupply + 1;
        _safeMint(msg.sender, totalSupply);
    }

    function widthDrawBalance() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return TOKEN_URI;
    }

    // Disable this function to avoid unnecessary ownership operations, which may lead to losing the contract's control forever.
    function renounceOwnership() public pure override {
        require(false, "can't renounce");
    }

    function _verifyProof(bytes32[] memory proof, uint256 index, address addr) private view {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(addr, index))));
        require(MerkleProof.verify(proof, _merkleRoot, leaf), "Invalid proof");
    }
}
