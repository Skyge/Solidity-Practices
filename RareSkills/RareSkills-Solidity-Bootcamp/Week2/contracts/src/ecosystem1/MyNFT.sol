// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Royalty} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title My NFT Contract
 * @author Skyge
 * @notice Set a default royalty fee for every NFT.
 * @dev This contract is used to create a NFT token.
 *      The NFT can be minted by the general users with a fixed price
 *      or by anyone who is valid in the Merkle Tree Account with a discount.
 */
contract MyNFT is Ownable2Step, ERC721Royalty {
    using BitMaps for BitMaps.BitMap;

    uint256 public constant PRICE = 0.1 ether;
    uint256 public constant DISCOUNT_PRICE = 0.08 ether;
    // 2.5% when `_feeDenominator` is 10000
    uint96 public constant ROYALTY_FEE = 250;
    uint256 public constant MAX_SUPPLY = 1000;
    bytes32 private immutable merkleRoot;

    uint256 public currentTokenId;
    BitMaps.BitMap private hasClaimed;

    event Mint(address indexed account, uint256 indexed tokenId);
    event MintWithDiscount(address indexed account, uint256 indexed tokenId);

    error RoyaltyFeeRecipientIsZeroAddress();
    error MintLimitReached();
    error InsufficientPayment();
    error InvalidProof();
    error HasClaimedByDiscount();
    error WithdrawFailed();

    /*//////////////////////////////////////////////////////////////
                           Constructor
    //////////////////////////////////////////////////////////////*/
    constructor(address _royaltyFeeRecipient, bytes32 _merkleRoot) Ownable(msg.sender) ERC721("My NFT", "MN") {
        if (_royaltyFeeRecipient == address(0)) {
            revert RoyaltyFeeRecipientIsZeroAddress();
        }
        currentTokenId = 0;

        merkleRoot = _merkleRoot;

        _setDefaultRoyalty(_royaltyFeeRecipient, ROYALTY_FEE);
    }

    /*//////////////////////////////////////////////////////////////
                           Owner function
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Only owner can call this function.
     * @dev Withdraw the contract's balance to an account.
     * @param to The address to receive the funds.
     */
    function withdrawFunds(address to) external onlyOwner {
        (bool succeed,) = to.call{value: address(this).balance}("");
        if (!succeed) {
            revert WithdrawFailed();
        }
    }

    /*//////////////////////////////////////////////////////////////
                           External functions
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice General users mint new NFT with a fixed price when does not reach mint limit.
     * @dev Mint the NFT to the specified address.
     * @param to The address to receive the minted NFT.
     */
    function safeMint(address to) external payable {
        if (currentTokenId >= MAX_SUPPLY) {
            revert MintLimitReached();
        }

        if (msg.value < PRICE) {
            revert InsufficientPayment();
        }

        // Mint the NFT
        _safeMint(to, currentTokenId);
        emit Mint(msg.sender, currentTokenId);

        // Set royalty info for the NFT
        (address royaltyReceiver,) = royaltyInfo(currentTokenId, PRICE);
        _setTokenRoyalty(currentTokenId, royaltyReceiver, ROYALTY_FEE);

        // Accumulate the token ID
        currentTokenId++;
    }

    /**
     * @notice Special users mint new NFT with a discount when does not reach mint limit.
     * @dev Mint the NFT to the specified address with a discount.
     * @param proof The Merkle proof to verify the discount.
     * @param to The address to receive the minted NFT.
     */
    function safeMintWithDiscount(bytes32[] calldata proof, address to) external payable {
        if (currentTokenId >= MAX_SUPPLY) {
            revert MintLimitReached();
        }

        // Check if the user has claimed the discount
        if (hasClaimed.get(uint256(uint160(msg.sender)))) {
            revert HasClaimedByDiscount();
        }

        // Verify the Merkle proof
        _verifyDiscountProof(proof, to);

        if (msg.value < DISCOUNT_PRICE) {
            revert InsufficientPayment();
        }

        // Mint the NFT
        _safeMint(to, currentTokenId);
        emit MintWithDiscount(msg.sender, currentTokenId);

        // Mark the user has claimed the discount
        hasClaimed.setTo(uint256(uint160(msg.sender)), true);

        // Set royalty info for the NFT
        (address royaltyReceiver,) = royaltyInfo(currentTokenId, DISCOUNT_PRICE);
        _setTokenRoyalty(currentTokenId, royaltyReceiver, ROYALTY_FEE);

        // Accumulate the token ID
        currentTokenId++;
    }

    /*//////////////////////////////////////////////////////////////
                        External view function
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Check if the user has claimed the discount.
     * @param account The address to check.
     */
    function hasClaimedDiscount(address account) external view returns (bool) {
        return hasClaimed.get(uint256(uint160(account)));
    }

    /*//////////////////////////////////////////////////////////////
                        Internal view function
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Verify the Merkle proof for the discount account.
     * @param proof The Merkle proof to verify.
     * @param to The address to verify.
     */
    function _verifyDiscountProof(bytes32[] memory proof, address to) internal view {
        // The leaves are double-hashed1 to prevent second pre-image attacks.
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(to))));

        if (!MerkleProof.verify(proof, merkleRoot, leaf)) {
            revert InvalidProof();
        }
    }
}
