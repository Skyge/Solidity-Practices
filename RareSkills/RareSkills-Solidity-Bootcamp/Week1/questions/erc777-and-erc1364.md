- **1.1 what problems ERC777 and ERC1363 solves?**
  - Allow contracts to receive tokens in a single transaction, rather than two different transactions that calling `approve()` and then calling `transferFrom()` for ERC20 tokens.

- **1.2 what issues are there with ERC777?**
  - 1. ERC777 is designed to be backwards compatible with the ERC20 token, but is more complex, requiring an additional call to the ERC1820 registry contract, which increases the cost of gas.
  - 2. The flexibility offered by hooks and callbacks can be exploited for malicious purposes, such as reentrancy or transaction revert.

- **1.3 Why was ERC1363 introduced?**
  - ERC777 tokens have the pitfalls as above, so ERC1363 was introduced to provide a more secure and efficient way to handle token interactions with contracts in a single transaction.

## References

- [ERC777](https://eips.ethereum.org/EIPS/eip-777)
- [Deprecate ERC777 implementation](https://github.com/OpenZeppelin/openzeppelin-contracts/issues/2620)
- [ERC1363](https://eips.ethereum.org/EIPS/eip-1363)
