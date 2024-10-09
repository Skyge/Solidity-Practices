// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {RewardToken} from "./RewardToken.sol";

/**
 * @title NFT Staking Contract
 * @author Skyge
 * @notice Transfer NFTs directly to this contract rather than call function to stake.
 * @dev This contract is used to stake NFTs and claim rewards.
 */
contract NFTStaking {
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 public constant DAILY_REWARD_AMOUNT = 10e18;
    address public immutable nft;
    address public immutable rewardToken;

    struct NFTInfo {
        address owner;
        uint256 lastClaimedTime;
    }

    mapping(uint256 tokenId => NFTInfo nftInfo) public tokenIdToNFTInfo;
    // All token ids staked by an account
    mapping(address account => EnumerableSet.UintSet tokenIds) internal accountToTokenIds;

    event NFTStaked(address indexed account, uint256 indexed tokenId);
    event NFTUnstaked(address indexed account, uint256 indexed tokenId);
    event Claimed(address indexed account, uint256 indexed tokenId, uint256 indexed rewardsAmount);

    error NFTAddressIsZeroAddress();
    error RewardTokenAddressIsZeroAddress();
    error FailedToAddTokenIdToAccount();
    error FailedToRemoveTokenIdFromAccount();
    error NotOwnerOfNFT();
    error CallerIsNotTheNFT();

    /*//////////////////////////////////////////////////////////////
                           Constructor
    //////////////////////////////////////////////////////////////*/
    constructor(address _nft, address _rewardToken) {
        if (_nft == address(0)) {
            revert NFTAddressIsZeroAddress();
        }
        if (_rewardToken == address(0)) {
            revert RewardTokenAddressIsZeroAddress();
        }

        nft = _nft;
        rewardToken = _rewardToken;
    }

    /*//////////////////////////////////////////////////////////////
                           External functions
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Transfer NFT directly to this contract will call this hook.
     * @dev Stake NFTs to this contract.
     * @param from The address which previously owned the token.
     * @param tokenId The NFT token id.
     * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address, /*operator*/ address from, uint256 tokenId, bytes calldata /*data*/ )
        external
        returns (bytes4)
    {
        // `msg.sender` should be the NFT contract address.
        if (msg.sender != nft) {
            revert CallerIsNotTheNFT();
        }
        // Record the NFT infos.
        NFTInfo memory nftInfo = NFTInfo({owner: from, lastClaimedTime: block.timestamp});
        tokenIdToNFTInfo[tokenId] = nftInfo;

        if (!accountToTokenIds[from].add(tokenId)) {
            revert FailedToAddTokenIdToAccount();
        }

        emit NFTStaked(from, tokenId);

        return this.onERC721Received.selector;
    }

    /**
     * @notice Will claim rewards at the same time.
     * @dev Unstake NFTs from this contract.
     * @param tokenId The NFT token id.
     */
    function withdrawNFT(uint256 tokenId) external {
        NFTInfo memory nftInfo = tokenIdToNFTInfo[tokenId];
        if (msg.sender != nftInfo.owner) {
            revert NotOwnerOfNFT();
        }

        if (!accountToTokenIds[msg.sender].remove(tokenId)) {
            revert FailedToRemoveTokenIdFromAccount();
        }

        // Claim rewards
        uint256 dayPassed = (block.timestamp - nftInfo.lastClaimedTime) / 1 days;
        uint256 rewardsAmount = dayPassed * DAILY_REWARD_AMOUNT;
        if (rewardsAmount > 0) {
            RewardToken(rewardToken).mint(msg.sender, rewardsAmount);
            emit Claimed(msg.sender, tokenId, rewardsAmount);
        }

        // Delete the NFT info
        delete tokenIdToNFTInfo[tokenId];

        // Transfer NFT back to the owner
        IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);
        emit NFTUnstaked(msg.sender, tokenId);
    }

    /**
     * @notice Staking time will be rounded down.
     * @dev Claim rewards for the specified NFT.
     * @param tokenId The NFT token id.
     */
    function claim(uint256 tokenId) external {
        NFTInfo storage nftInfo = tokenIdToNFTInfo[tokenId];
        if (msg.sender != nftInfo.owner) {
            revert NotOwnerOfNFT();
        }

        uint256 dayPassed = (block.timestamp - nftInfo.lastClaimedTime) / 1 days;
        uint256 rewardsAmount = dayPassed * DAILY_REWARD_AMOUNT;
        if (rewardsAmount > 0) {
            RewardToken(rewardToken).mint(msg.sender, rewardsAmount);
            emit Claimed(msg.sender, tokenId, rewardsAmount);

            // Update the last claimed time
            nftInfo.lastClaimedTime = nftInfo.lastClaimedTime + dayPassed * 1 days;
        }
    }

    /*//////////////////////////////////////////////////////////////
                           External view function
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Get all token ids staked by an account.
     * @param account The account to query.
     * @return The token ids staked by the account.
     */
    function getStakedTokenIds(address account) external view returns (uint256[] memory) {
        return accountToTokenIds[account].values();
    }
}
