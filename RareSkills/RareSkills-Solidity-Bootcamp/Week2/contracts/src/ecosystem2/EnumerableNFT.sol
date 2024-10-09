// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**
 * @title Enumerable NFT Contract
 * @author Skyge
 * @notice The token id starts from 1.
 * @notice This contract is used to create a NFT token with a limited supply.
 */
contract EnumerableNFT is ERC721Enumerable {
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public currentTokenId;

    error MintLimitReached();

    /*//////////////////////////////////////////////////////////////
                           Constructor
    //////////////////////////////////////////////////////////////*/
    constructor() ERC721("EnumerableNFT", "ENFT") {
        currentTokenId = 0;
    }

    /*//////////////////////////////////////////////////////////////
                           External function
    //////////////////////////////////////////////////////////////*/
    function safeMint(address to) external {
        if (currentTokenId > MAX_SUPPLY) {
            revert MintLimitReached();
        }

        currentTokenId++;
        _safeMint(to, currentTokenId);
    }
}
