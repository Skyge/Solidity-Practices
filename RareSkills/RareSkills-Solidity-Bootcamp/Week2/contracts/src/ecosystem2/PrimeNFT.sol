// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**
 * @title Enumerable NFT Contract
 * @author Skyge
 * @notice The token id starts from 1.
 * @dev This contract is used to create a NFT token,
 *      it can return the number of prime token ids owned by an account.
 */
contract PrimeNFT is ERC721Enumerable {
    uint256 public currentTokenId;

    error MintLimitReached();

    /*//////////////////////////////////////////////////////////////
                           Constructor
    //////////////////////////////////////////////////////////////*/
    constructor() ERC721("EnumerableNFT", "ENFT") {
        currentTokenId = 1;
    }

    /*//////////////////////////////////////////////////////////////
                           External function
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Mint a new NFT token
     * @param to The account to receive the NFT token
     */
    function safeMint(address to) external {
        _safeMint(to, currentTokenId);

        currentTokenId++;
    }

    /*//////////////////////////////////////////////////////////////
                           External view function
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Count the number of prime token ids owned by the account
     * @param account The account to query
     * @return primeCounts The number of prime token ids
     */
    function primeIdCounts(address account) external view returns (uint256 primeCounts) {
        // The total number of nft owned by the account
        uint256 totalNFTs = balanceOf(account);

        for (uint256 i; i < totalNFTs; ++i) {
            // Corresponding token ids
            uint256 tokenId = tokenOfOwnerByIndex(account, i);

            if (isPrime(tokenId)) {
                ++primeCounts;
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                           Internal view function
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Check if a number is prime
     */
    function isPrime(uint256 number) internal pure returns (bool) {
        if (number <= 1) {
            return false;
        }

        uint256 i = 2;
        do {
            if (i * i > number) {
                break;
            }
            if (number % i == 0) {
                return false;
            }
            ++i;
        } while (true);

        return true;
    }
}
