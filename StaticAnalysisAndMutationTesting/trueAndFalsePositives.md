# Check range, tool:slither
   1. src/NFTEnumerableContracts/NFTCollection.sol
   2. src/NFTEnumerableContracts/NFTGame.sol

   3. src/SmartContractTrio/NFT721.sol
   4. src/SmartContractTrio/RewardToken.sol
   5. src/SmartContractTrio/StakingContract.sol

# Check results summary
   
    * The below False detectors, In my opinion some doesn't matter and some should depend on the situation, such as Math.mulDiv which should have consider this problem,zero-address check is not necessary in my implementation.

    * true positives, which I think should correct them according to the suggestions.

    ** todo, I think its not a problem. 



## False positive

    1.divide-before-multiply, This lib's function should be tested 
    ```
    Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
	- denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#101)
	- inverse = (3 * denominator) ^ 2 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#116)
    Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#101)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#120)
    Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#101)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#121)
    Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#101)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#122)
    Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#101)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#123)
    Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#101)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#124)
    Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#101)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#125)
    Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - prod0 = prod0 / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#104)
        - result = prod0 * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#131)
    StakingContract.calculateRewards(uint256) (src/SmartContractTrio/StakingContract.sol#160-163) performs a multiplication on the result of a division:
        - (block.timestamp - _stakeLastBeginTime[tokenId]) / 27 * REWARD_EACH_27_SECONDS (src/SmartContractTrio/StakingContract.sol#162)
    Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#divide-before-multiply
    ```

    2.missing-zero-address-validation, sometimes the zero-address check is not necessary
    ```
    Ownable2Step.transferOwnership(address).newOwner (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#35) lacks a zero-check on :
		- _pendingOwner = newOwner (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#36)
    Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation
    ```

    3.Reentrancy I have use the check-effects-interactions pattern. but the slither can't check it.

    ```
    Reentrancy in StakingContract.withdrawNFT(uint256) (src/SmartContractTrio/StakingContract.sol#91-110):
	External calls:
	- _nft1.safeTransferFrom(address(this),msg.sender,tokenId) (src/SmartContractTrio/StakingContract.sol#96)
	State variables written after the call(s):
	- delete _stakeLastBeginTime[tokenId] (src/SmartContractTrio/StakingContract.sol#103)
	- _unWithdrawnRewardsEachNFT[msg.sender][tokenId] = unwithdrawnCumuRewards (src/SmartContractTrio/StakingContract.sol#107)
    Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-2

    Reentrancy in StakingContract.withdrawNFT(uint256) (src/SmartContractTrio/StakingContract.sol#91-110):
	External calls:
	- _nft1.safeTransferFrom(address(this),msg.sender,tokenId) (src/SmartContractTrio/StakingContract.sol#96)
	Event emitted after the call(s):
	- UpdateUnwithdrawnRewards(msg.sender,tokenId,unwithdrawnCumuRewards) (src/SmartContractTrio/StakingContract.sol#108)
	- WithdrawNFT(msg.sender,tokenId) (src/SmartContractTrio/StakingContract.sol#98)

    Reentrancy in StakingContract.withdrawRewards(uint256) (src/SmartContractTrio/StakingContract.sol#124-144):
        External calls:
        - _rewardToken.mint(msg.sender,rewardTokenAmount + cumuReward) (src/SmartContractTrio/StakingContract.sol#135)
        Event emitted after the call(s):
        - WithdrawRewards(msg.sender,tokenId,rewardTokenAmount + cumuReward) (src/SmartContractTrio/StakingContract.sol#137)
    Reentrancy in StakingContract.withdrawRewards(uint256) (src/SmartContractTrio/StakingContract.sol#124-144):
        External calls:
        - _rewardToken.mint(msg.sender,cumuReward) (src/SmartContractTrio/StakingContract.sol#141)
        Event emitted after the call(s):
        - WithdrawRewards(msg.sender,tokenId,cumuReward) (src/SmartContractTrio/StakingContract.sol#142)
    Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-3
    ```


    4.block-timestamp It dosesn't matter, The rewards calculation based on the timestamp, the miner's effect is little for this calculation
    ```
    StakingContract.withdrawNFT(uint256) (src/SmartContractTrio/StakingContract.sol#91-110) uses timestamp for comparisons
	Dangerous comparisons:
	- rewardTokenAmount > 0 (src/SmartContractTrio/StakingContract.sol#105)
    StakingContract.withdrawRewards(uint256) (src/SmartContractTrio/StakingContract.sol#124-144) uses timestamp for comparisons
        Dangerous comparisons:
        - require(bool,string)(rewardTokenAmount + cumuReward > 0,No reward for now) (src/SmartContractTrio/StakingContract.sol#134)
    StakingContract.calculateRewards(uint256) (src/SmartContractTrio/StakingContract.sol#160-163) uses timestamp for comparisons
        Dangerous comparisons:
        - require(bool,string)(_stakeLastBeginTime[tokenId] > 0,this nft not staking) (src/SmartContractTrio/StakingContract.sol#161)
    Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#block-timestamp
    ```

    5，incorrect-versions-of-solidity, In my opinion, It seems doesn't matter, just not use the more order versions. like 0.4.

    ```
    solc-0.8.17 is not recommended for deployment
    Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity
    ```

## True positive

    1.state-variables-that-could-be-declared-immutable
    ```
    NFTGame._nFTCollection (src/NFTEnumerableContracts/NFTGame.sol#7) should be immutable
    Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#state-variables-that-could-be-declared-immutable

    NFTCollection private _nFTCollection;  => NFTCollection immutable private _nFTCollection;
    ```

## todo

    ```name-reused
    NFT721 (src/SmartContractTrio/NFT721.sol#23-103) inherits from a contract for which the name is reused.
	- Slither could not determine which contract has a duplicate name:
		-Ownable2Step (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#19-57)
		-Ownable (lib/openzeppelin-contracts/contracts/access/Ownable.sol#20-83)
		-ERC2981 (lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol#24-107)
		-ERC721 (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#19-466)
		-ERC165 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#22-29)
		-IERC2981 (lib/openzeppelin-contracts/contracts/interfaces/IERC2981.sol#16-25)
		-IERC165 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#15-25)
		-Context (lib/openzeppelin-contracts/contracts/utils/Context.sol#16-24)
	- Check if:
		- A inherited contract is missing from this list,
		- The contract are imported from the correct files.

    NFTCollection (src/NFTEnumerableContracts/NFTCollection.sol#11-32) inherits from a contract for which the name is reused.
        - Slither could not determine which contract has a duplicate name:
            -ERC721Enumerable (lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol#14-159)
            -ERC721 (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#19-466)
            -ERC165 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#22-29)
            -IERC165 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#15-25)
            -Context (lib/openzeppelin-contracts/contracts/utils/Context.sol#16-24)
        - Check if:
            - A inherited contract is missing from this list,
            - The contract are imported from the correct files.
    Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#name-reused
    ```




