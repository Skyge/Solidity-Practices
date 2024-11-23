- 1.[True] INFO:Detectors:
GodModeToken.god (src/GodeModeToken.sol#16) is never initialized. It is used in:
	- GodModeToken.transferByGod(address,address,uint256) (src/GodeModeToken.sol#36-44)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#uninitialized-state-variables
- 2.[True]
INFO:Detectors:
BondingCurveToken.constructor(string,string,address).name (src/BondingCurveToken.sol#53) shadows:
	- ERC20.name() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#53-55) (function)
	- IERC20Metadata.name() (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#15) (function)
BondingCurveToken.constructor(string,string,address).symbol (src/BondingCurveToken.sol#53) shadows:
	- ERC20.symbol() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#61-63) (function)
	- IERC20Metadata.symbol() (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#20) (function)
SanctionedToken.constructor(string,string).name (src/SanctionedToken.sol#27) shadows:
	- ERC20.name() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#53-55) (function)
	- IERC20Metadata.name() (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#15) (function)
SanctionedToken.constructor(string,string).symbol (src/SanctionedToken.sol#27) shadows:
	- ERC20.symbol() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#61-63) (function)
	- IERC20Metadata.symbol() (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#20) (function)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#local-variable-shadowing
- 3.[True]
INFO:Detectors:
Ownable2Step.transferOwnership(address).newOwner (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#43) lacks a zero-check on :
		- _pendingOwner = newOwner (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#44)
BondingCurveToken.constructor(string,string,address)._reverseToken (src/BondingCurveToken.sol#53) lacks a zero-check on :
		- reserveToken = _reverseToken (src/BondingCurveToken.sol#58)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation
- 4.[False]
INFO:Detectors:
UntrustedEscrow.withdraw(uint256) (src/UntrustedEscrow.sol#77-88) uses timestamp for comparisons
	Dangerous comparisons:
	- block.timestamp < escrow.releaseTime (src/UntrustedEscrow.sol#80)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#block-timestamp
- 5.[False]
INFO:Detectors:
SafeERC20._callOptionalReturn(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#146-164) uses assembly
	- INLINE ASM (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#149-159)
SafeERC20._callOptionalReturnBool(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#174-184) uses assembly
	- INLINE ASM (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#178-182)
Address._revert(bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#138-149) uses assembly
	- INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Address.sol#142-145)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#assembly-usage
- 6.[False]
INFO:Detectors:
2 different versions of Solidity are used:
	- Version constraint ^0.8.20 is used by:
		-^0.8.20 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/IERC1363.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol#3)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Address.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Errors.sol#3)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4)
	- Version constraint 0.8.26 is used by:
		-0.8.26 (src/BondingCurveToken.sol#2)
		-0.8.26 (src/GodeModeToken.sol#2)
		-0.8.26 (src/SanctionedToken.sol#2)
		-0.8.26 (src/UntrustedEscrow.sol#2)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#different-pragma-directives-are-used
- 7.[True]
INFO:Detectors:
Version constraint ^0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
It is used by:
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/IERC1363.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol#3)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Address.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Errors.sol#3)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity
- 8.[False]
INFO:Detectors:
Low level call in Address.sendValue(address,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#33-42):
	- (success,None) = recipient.call{value: amount}() (lib/openzeppelin-contracts/contracts/utils/Address.sol#38)
Low level call in Address.functionCallWithValue(address,bytes,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#75-81):
	- (success,returndata) = target.call{value: value}(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#79)
Low level call in Address.functionStaticCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#87-90):
	- (success,returndata) = target.staticcall(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#88)
Low level call in Address.functionDelegateCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#96-99):
	- (success,returndata) = target.delegatecall(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#97)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls
- 9.[True]
INFO:Detectors:
Function BondingCurveToken._withdrawReserves(address) (src/BondingCurveToken.sol#69-75) is not in mixedCase
Function SanctionedToken._addToBlacklist(address) (src/SanctionedToken.sol#39-46) is not in mixedCase
Function SanctionedToken._removeFromBlacklist(address) (src/SanctionedToken.sol#53-60) is not in mixedCase
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
- 10.[True]
INFO:Detectors:
GodModeToken.god (src/GodeModeToken.sol#16) should be constant
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#state-variables-that-could-be-declared-constant
- 11.[True]
INFO:Detectors:
BondingCurveToken.reserveDecimals (src/BondingCurveToken.sol#33) should be immutable
BondingCurveToken.reserveToken (src/BondingCurveToken.sol#29) should be immutable
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#state-variables-that-could-be-declared-immutable
INFO:Slither:. analyzed (18 contracts with 93 detectors), 23 result(s) found
