- **1.1 How does ERC721A save gas?**
  - ERC721A implements batch minting/burning/transferring(transferFrom), so users can mint/burn/transfer multiple nfts in a single transaction
  - Removing duplicate storage from ERC721Enumerable. For example `_ownedTokens`, `_ownedTokensIndex`,` _allTokens`, and `_allTokensIndex`, and use some new structs, `TokenOwnership`,  `AddressData` to replace them.

- **1.2 Where does it add cost?**
  - `transferFrom` and `safeTransferFrom` may cost more gas. The ERC721A does not set an explicit owner for every token id, they use consecutive token ids when minting by the same owner. So when transfer by token id, the contract has to run a loop across all of the token ids until it reaches the first NFT with an explicit owner address to find the owner that has the right to transfer it

## References

- [Azuki](https://www.azuki.com/erc721a)
- [ERC721A](https://github.com/chiru-labs/ERC721A/blob/main/contracts/ERC721A.sol)
