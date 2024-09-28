- **1.1 Why does the SafeERC20 program exist?**
  - Not all ERC20 tokens are standard ERC20 tokens, for example some tokens do not return a bool (e.g. USDT) on ERC20 methods, and some tokens do not revert on failure but return false (e.g. ZRX) and so on, so this library is used to deal with these special circumstances.

- **1.2 When should it be used?**
  - 1. When dealing with unknown or non-standard ERC20 tokens.
  - 2. To enhance the security and reliability of smart contracts interacting with ERC20 tokens.

## References

- [SafeERC20.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol)
- [ERC20 security issues](https://medium.com/@deliriusz/ten-issues-with-erc20s-that-can-ruin-you-smart-contract-6c06c44948e0)
- [Weird ERC20 Tokens](https://github.com/d-xo/weird-erc20)
