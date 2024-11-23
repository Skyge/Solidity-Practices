- 1.[False]INFO:Detectors:
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#123-202) has bitwise-xor operator ^ instead of the exponentiation operator **:
	 - inverse = (3 * denominator) ^ 2 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#184)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-exponentiation
INFO:Detectors:
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#123-202) performs a multiplication on the result of a division:
	- denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#169)
	- inverse = (3 * denominator) ^ 2 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#184)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#123-202) performs a multiplication on the result of a division:
	- denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#169)
	- inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#188)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#123-202) performs a multiplication on the result of a division:
	- denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#169)
	- inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#189)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#123-202) performs a multiplication on the result of a division:
	- denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#169)
	- inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#190)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#123-202) performs a multiplication on the result of a division:
	- denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#169)
	- inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#191)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#123-202) performs a multiplication on the result of a division:
	- denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#169)
	- inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#192)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#123-202) performs a multiplication on the result of a division:
	- denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#169)
	- inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#193)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#123-202) performs a multiplication on the result of a division:
	- prod0 = prod0 / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#172)
	- result = prod0 * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#199)
NFTStaking.withdrawNFT(uint256) (src/ecosystem1/NFTStaking.sol#92-116) performs a multiplication on the result of a division:
	- dayPassed = (block.timestamp - nftInfo.lastClaimedTime) / 86400 (src/ecosystem1/NFTStaking.sol#103)
	- rewardsAmount = dayPassed * DAILY_REWARD_AMOUNT (src/ecosystem1/NFTStaking.sol#104)
NFTStaking.claim(uint256) (src/ecosystem1/NFTStaking.sol#123-138) performs a multiplication on the result of a division:
	- dayPassed = (block.timestamp - nftInfo.lastClaimedTime) / 86400 (src/ecosystem1/NFTStaking.sol#129)
	- rewardsAmount = dayPassed * DAILY_REWARD_AMOUNT (src/ecosystem1/NFTStaking.sol#130)
NFTStaking.claim(uint256) (src/ecosystem1/NFTStaking.sol#123-138) performs a multiplication on the result of a division:
	- dayPassed = (block.timestamp - nftInfo.lastClaimedTime) / 86400 (src/ecosystem1/NFTStaking.sol#129)
	- nftInfo.lastClaimedTime = nftInfo.lastClaimedTime + dayPassed * 86400 (src/ecosystem1/NFTStaking.sol#136)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#divide-before-multiply
- 2.[True]INFO:Detectors:
Reentrancy in NFTStaking.claim(uint256) (src/ecosystem1/NFTStaking.sol#123-138):
	External calls:
	- RewardToken(rewardToken).mint(msg.sender,rewardsAmount) (src/ecosystem1/NFTStaking.sol#132)
	State variables written after the call(s):
	- nftInfo.lastClaimedTime = nftInfo.lastClaimedTime + dayPassed * 86400 (src/ecosystem1/NFTStaking.sol#136)
	NFTStaking.tokenIdToNFTInfo (src/ecosystem1/NFTStaking.sol#26) can be used in cross function reentrancies:
	- NFTStaking.claim(uint256) (src/ecosystem1/NFTStaking.sol#123-138)
	- NFTStaking.onERC721Received(address,address,uint256,bytes) (src/ecosystem1/NFTStaking.sol#66-85)
	- NFTStaking.tokenIdToNFTInfo (src/ecosystem1/NFTStaking.sol#26)
	- NFTStaking.withdrawNFT(uint256) (src/ecosystem1/NFTStaking.sol#92-116)
Reentrancy in NFTStaking.withdrawNFT(uint256) (src/ecosystem1/NFTStaking.sol#92-116):
	External calls:
	- RewardToken(rewardToken).mint(msg.sender,rewardsAmount) (src/ecosystem1/NFTStaking.sol#106)
	State variables written after the call(s):
	- delete tokenIdToNFTInfo[tokenId] (src/ecosystem1/NFTStaking.sol#111)
	NFTStaking.tokenIdToNFTInfo (src/ecosystem1/NFTStaking.sol#26) can be used in cross function reentrancies:
	- NFTStaking.claim(uint256) (src/ecosystem1/NFTStaking.sol#123-138)
	- NFTStaking.onERC721Received(address,address,uint256,bytes) (src/ecosystem1/NFTStaking.sol#66-85)
	- NFTStaking.tokenIdToNFTInfo (src/ecosystem1/NFTStaking.sol#26)
	- NFTStaking.withdrawNFT(uint256) (src/ecosystem1/NFTStaking.sol#92-116)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-1
- 3.[True]INFO:Detectors:
Ownable2Step.transferOwnership(address).newOwner (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#35) lacks a zero-check on :
		- _pendingOwner = newOwner (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#36)
MyNFT.withdrawFunds(address).to (src/ecosystem1/MyNFT.sol#65) lacks a zero-check on :
		- (succeed,None) = to.call{value: totalFunds}() (src/ecosystem1/MyNFT.sol#67)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation
- 4.[True]INFO:Detectors:
Reentrancy in NFTStaking.claim(uint256) (src/ecosystem1/NFTStaking.sol#123-138):
	External calls:
	- RewardToken(rewardToken).mint(msg.sender,rewardsAmount) (src/ecosystem1/NFTStaking.sol#132)
	Event emitted after the call(s):
	- Claimed(msg.sender,tokenId,rewardsAmount) (src/ecosystem1/NFTStaking.sol#133)
Reentrancy in MyNFT.safeMint(address) (src/ecosystem1/MyNFT.sol#83-98):
	External calls:
	- _safeMint(to,currentTokenId) (src/ecosystem1/MyNFT.sol#96)
		- retval = IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#467-480)
	Event emitted after the call(s):
	- Mint(msg.sender,currentTokenId) (src/ecosystem1/MyNFT.sol#97)
Reentrancy in MyNFT.safeMintWithDiscount(bytes32[],address) (src/ecosystem1/MyNFT.sol#107-133):
	External calls:
	- _safeMint(to,currentTokenId) (src/ecosystem1/MyNFT.sol#131)
		- retval = IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#467-480)
	Event emitted after the call(s):
	- MintWithDiscount(msg.sender,currentTokenId) (src/ecosystem1/MyNFT.sol#132)
Reentrancy in MyNFT.withdrawFunds(address) (src/ecosystem1/MyNFT.sol#65-73):
	External calls:
	- (succeed,None) = to.call{value: totalFunds}() (src/ecosystem1/MyNFT.sol#67)
	Event emitted after the call(s):
	- WithdrawFunds(to,totalFunds) (src/ecosystem1/MyNFT.sol#72)
Reentrancy in NFTStaking.withdrawNFT(uint256) (src/ecosystem1/NFTStaking.sol#92-116):
	External calls:
	- RewardToken(rewardToken).mint(msg.sender,rewardsAmount) (src/ecosystem1/NFTStaking.sol#106)
	Event emitted after the call(s):
	- Claimed(msg.sender,tokenId,rewardsAmount) (src/ecosystem1/NFTStaking.sol#107)
Reentrancy in NFTStaking.withdrawNFT(uint256) (src/ecosystem1/NFTStaking.sol#92-116):
	External calls:
	- RewardToken(rewardToken).mint(msg.sender,rewardsAmount) (src/ecosystem1/NFTStaking.sol#106)
	- IERC721(nft).safeTransferFrom(address(this),msg.sender,tokenId) (src/ecosystem1/NFTStaking.sol#114)
	Event emitted after the call(s):
	- NFTUnstaked(msg.sender,tokenId) (src/ecosystem1/NFTStaking.sol#115)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-3
- 5.[False]INFO:Detectors:
NFTStaking.withdrawNFT(uint256) (src/ecosystem1/NFTStaking.sol#92-116) uses timestamp for comparisons
	Dangerous comparisons:
	- msg.sender != nftInfo.owner (src/ecosystem1/NFTStaking.sol#94)
	- rewardsAmount > 0 (src/ecosystem1/NFTStaking.sol#105)
NFTStaking.claim(uint256) (src/ecosystem1/NFTStaking.sol#123-138) uses timestamp for comparisons
	Dangerous comparisons:
	- rewardsAmount > 0 (src/ecosystem1/NFTStaking.sol#131)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#block-timestamp
- 6.[False]INFO:Detectors:
ERC721._checkOnERC721Received(address,address,uint256,bytes) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#465-482) uses assembly
	- INLINE ASM (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#476-478)
Strings.toString(uint256) (lib/openzeppelin-contracts/contracts/utils/Strings.sol#24-44) uses assembly
	- INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Strings.sol#30-32)
	- INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Strings.sol#36-38)
MerkleProof._efficientHash(bytes32,bytes32) (lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#224-231) uses assembly
	- INLINE ASM (lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#226-230)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#123-202) uses assembly
	- INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#130-133)
	- INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#154-161)
	- INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#167-176)
EnumerableSet.values(EnumerableSet.Bytes32Set) (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol#219-229) uses assembly
	- INLINE ASM (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol#224-226)
EnumerableSet.values(EnumerableSet.AddressSet) (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol#293-303) uses assembly
	- INLINE ASM (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol#298-300)
EnumerableSet.values(EnumerableSet.UintSet) (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol#367-377) uses assembly
	- INLINE ASM (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol#372-374)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#assembly-usage
- 7.[False]INFO:Detectors:
2 different versions of Solidity are used:
	- Version constraint ^0.8.20 is used by:
		-^0.8.20 (lib/openzeppelin-contracts/contracts/access/AccessControl.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/access/IAccessControl.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/IERC2981.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol#3)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Royalty.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Strings.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/utils/structs/BitMaps.sol#3)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol#5)
	- Version constraint 0.8.26 is used by:
		-0.8.26 (src/ecosystem1/MyNFT.sol#2)
		-0.8.26 (src/ecosystem1/NFTStaking.sol#2)
		-0.8.26 (src/ecosystem1/RewardToken.sol#2)
		-0.8.26 (src/ecosystem2/EnumerableNFT.sol#2)
		-0.8.26 (src/ecosystem2/PrimeNFT.sol#2)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#different-pragma-directives-are-used
- 8.[True]INFO:Detectors:
Version constraint ^0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
It is used by:
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/access/AccessControl.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/access/IAccessControl.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/IERC2981.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol#3)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Royalty.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Strings.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/structs/BitMaps.sol#3)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol#5)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity
- 9.[False]INFO:Detectors:
Low level call in MyNFT.withdrawFunds(address) (src/ecosystem1/MyNFT.sol#65-73):
	- (succeed,None) = to.call{value: totalFunds}() (src/ecosystem1/MyNFT.sol#67)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls
- 10.[True]INFO:Detectors:
NFTStaking (src/ecosystem1/NFTStaking.sol#14-151) should inherit from IERC721Receiver (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol#11-28)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-inheritance
INFO:Slither:. analyzed (33 contracts with 93 detectors), 35 result(s) found
