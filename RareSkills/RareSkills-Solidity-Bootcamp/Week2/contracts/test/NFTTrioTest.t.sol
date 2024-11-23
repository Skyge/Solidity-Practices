// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyNFT} from "../src/ecosystem1/MyNFT.sol";
import {RewardToken} from "../src/ecosystem1/RewardToken.sol";
import {NFTStaking} from "../src/ecosystem1/NFTStaking.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {DeployNFTTrio} from "../script/DeployNFTTrio.s.sol";

contract NFTTrioTest is Test {
    RewardToken public rewardToken;
    MyNFT public nft;
    NFTStaking public nftStaking;
    HelperConfig public helperConfig;
    address public discountAccount1;
    address alice = makeAddr("Alice");

    function setUp() external {
        DeployNFTTrio deployer = new DeployNFTTrio();
        (rewardToken, nft, nftStaking, helperConfig) = deployer.run();
        discountAccount1 = helperConfig.getConfig().discountAccount1;

        vm.deal(alice, 1000 ether);
        vm.deal(discountAccount1, 1000 ether);
    }

    // Revert when deploy contract if royalty fee recipient is zero address
    function testDeployWillFailRoyaltyFeeRecipientIsZeroAddress() external {
        // Deploy failed
        vm.expectRevert(MyNFT.RoyaltyFeeRecipientIsZeroAddress.selector);
        new MyNFT(address(0), bytes32(0));
    }

    /*//////////////////////////////////////////////////////////////
                           MyNFT Tests
    //////////////////////////////////////////////////////////////*/
    function testNormalMint() external {
        uint256 beforeTokenId = nft.currentTokenId();
        vm.prank(alice);
        nft.safeMint{value: 0.1 ether}(alice);
        assert(nft.ownerOf(beforeTokenId + 1) == alice);
        assert(nft.currentTokenId() == beforeTokenId + 1);
        assert(nft.balanceOf(alice) == 1);
        assert(address(nft).balance == 0.1 ether);
    }

    // Revert when minting if mint limit reached
    function testMintWillFailMintLimitReached() external {
        // Mint NFTs to reach the limit
        uint256 maxSupply = nft.MAX_SUPPLY();
        for (uint256 i; i < maxSupply; ++i) {
            nft.safeMint{value: 0.1 ether}(alice);
        }

        // Mint limit reached
        vm.expectRevert(MyNFT.MintLimitReached.selector);
        nft.safeMint{value: 0.1 ether}(alice);
    }

    // Revert when minting if insufficient payment
    function testMintWillFailInsufficientPayment() external {
        uint256 mintPrice = nft.PRICE();
        // Insufficient payment
        vm.expectRevert(MyNFT.InsufficientPayment.selector);
        nft.safeMint{value: mintPrice - 1}(alice);
    }

    function testMintWithDiscount() external {
        bytes32[] memory proof = new bytes32[](4);
        proof[0] = 0x208697df1b2d4c083944c10909fe1ed6e99c1eaccff33ba129464b28f8245f01;
        proof[1] = 0x6cc962fe200062ec5506465bba79ef2a025aa9e256958d797023b191d2753272;
        proof[2] = 0x1823bf464e3889ced384fe32a5a1543450346e714b7b4d2f9354a1709feca014;
        proof[3] = 0x2a3cb55154243e3bf9cfbb98f8ed87dd65f0f3f3c1e95e4a9e746c3b2b09d6a6;

        // Has not claimed with discount
        assert(!nft.hasClaimedDiscount(discountAccount1));
        uint256 beforeTokenId = nft.currentTokenId();

        vm.prank(discountAccount1);
        nft.safeMintWithDiscount{value: 0.08e18}(proof, discountAccount1);

        // Has claimed with discount
        assert(nft.hasClaimedDiscount(discountAccount1));
        assert(nft.ownerOf(beforeTokenId + 1) == discountAccount1);
        assert(nft.currentTokenId() == beforeTokenId + 1);
        assert(nft.balanceOf(discountAccount1) == 1);
        assert(address(nft).balance == 0.08 ether);
    }

    // Revert when minting with discount if mint limit reached
    function testMintWithDiscountWillFailMintLimitReached() external {
        // Mint NFTs to reach the limit
        uint256 maxSupply = nft.MAX_SUPPLY();
        for (uint256 i; i < maxSupply; ++i) {
            nft.safeMint{value: 0.1 ether}(alice);
        }

        bytes32[] memory proof = new bytes32[](0);

        // Mint limit reached
        vm.expectRevert(MyNFT.MintLimitReached.selector);
        nft.safeMintWithDiscount{value: 0.08e18}(proof, discountAccount1);
    }

    // Revert when minting with discount if has claimed by discount
    function testMintWithDiscountWillFailHasClaimedByDiscount() external {
        bytes32[] memory proof = new bytes32[](4);
        proof[0] = 0x208697df1b2d4c083944c10909fe1ed6e99c1eaccff33ba129464b28f8245f01;
        proof[1] = 0x6cc962fe200062ec5506465bba79ef2a025aa9e256958d797023b191d2753272;
        proof[2] = 0x1823bf464e3889ced384fe32a5a1543450346e714b7b4d2f9354a1709feca014;
        proof[3] = 0x2a3cb55154243e3bf9cfbb98f8ed87dd65f0f3f3c1e95e4a9e746c3b2b09d6a6;

        // Has claimed with discount
        vm.startPrank(discountAccount1);
        nft.safeMintWithDiscount{value: 0.08e18}(proof, discountAccount1);
        vm.expectRevert(MyNFT.HasClaimedByDiscount.selector);
        nft.safeMintWithDiscount{value: 0.08e18}(proof, discountAccount1);
        vm.stopPrank();
    }

    // Revert when minting with discount if insufficient payment
    function testMintWithDiscountWillFailInsufficientPayment() external {
        uint256 discountPrice = nft.DISCOUNT_PRICE();
        bytes32[] memory proof = new bytes32[](4);
        proof[0] = 0x208697df1b2d4c083944c10909fe1ed6e99c1eaccff33ba129464b28f8245f01;
        proof[1] = 0x6cc962fe200062ec5506465bba79ef2a025aa9e256958d797023b191d2753272;
        proof[2] = 0x1823bf464e3889ced384fe32a5a1543450346e714b7b4d2f9354a1709feca014;
        proof[3] = 0x2a3cb55154243e3bf9cfbb98f8ed87dd65f0f3f3c1e95e4a9e746c3b2b09d6a6;

        // Insufficient payment
        vm.expectRevert(MyNFT.InsufficientPayment.selector);
        nft.safeMintWithDiscount{value: discountPrice - 1}(proof, discountAccount1);
    }

    // Revert when minting with discount if proof is invalid
    function testMintWithDiscountWillFailInvalidProof() external {
        bytes32[] memory proof = new bytes32[](0);

        // Invalid proof
        vm.expectRevert(MyNFT.InvalidProof.selector);
        nft.safeMintWithDiscount{value: 0.08e18}(proof, alice);
    }

    function testWithdrawFunds() external {
        vm.prank(alice);
        nft.safeMint{value: 0.1 ether}(alice);
        assert(address(nft).balance == 0.1 ether);

        address owner = nft.owner();
        vm.prank(owner);
        nft.withdrawFunds(owner);
        assert(address(nft).balance == 0);
    }

    // Revert when withdrawing funds if not owner
    function testWithdrawFundsWillFailNotOwner() external {
        // Alice is not the owner
        assertTrue(nft.owner() != alice);
        vm.startPrank(alice);
        vm.expectRevert();
        nft.withdrawFunds(alice);
        vm.stopPrank();
    }

    // Revert when withdrawing funds if failed
    function testWithdrawFundsWillFailFailed() external {
        vm.prank(alice);
        nft.safeMint{value: 0.1 ether}(alice);
        assert(address(nft).balance == 0.1 ether);

        address owner = nft.owner();
        vm.startPrank(owner);
        vm.expectRevert(abi.encodeWithSelector(MyNFT.WithdrawFundsFailed.selector));
        // This contract does not have a function to receive ether, so it will revert
        nft.withdrawFunds(address(this));
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                           NFTStaking Tests
    //////////////////////////////////////////////////////////////*/
    // Revert when deploying contract if NFT address is zero address
    function testDeployWillFailNFTAddressIsZeroAddress() external {
        // Deploy failed
        vm.expectRevert(NFTStaking.NFTAddressIsZeroAddress.selector);
        new NFTStaking(address(0), address(rewardToken));
    }

    // Revert when deploying contract if reward token address is zero address
    function testDeployWillFailRewardTokenAddressIsZeroAddress() external {
        // Deploy failed
        vm.expectRevert(NFTStaking.RewardTokenAddressIsZeroAddress.selector);
        new NFTStaking(address(nft), address(0));
    }

    function testStakeNFT() public {
        vm.startPrank(alice);
        nft.safeMint{value: 0.1 ether}(alice);
        uint256 tokenId = nft.currentTokenId();
        // Transfer NFT to NFTStaking to stake
        nft.safeTransferFrom(alice, address(nftStaking), tokenId);
        vm.stopPrank();

        (address tokenIdOwner,) = nftStaking.tokenIdToNFTInfo(tokenId);
        assert(tokenIdOwner == alice);
        assert(nftStaking.getStakedTokenIds(alice).length == 1);
    }

    // Revert when staking NFT if caller is not the NFT
    function testStakeNFTWillFailNotOwner() external {
        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(NFTStaking.CallerIsNotTheNFT.selector));
        nftStaking.onERC721Received(alice, alice, 1, "");
        vm.stopPrank();
    }

    // Revert when staking the same NFT twice
    function testStakeNFTWillFailAlreadyStaked() external {
        testStakeNFT();
        uint256 tokenId = nft.currentTokenId();
        (address tokenIdOwner,) = nftStaking.tokenIdToNFTInfo(tokenId);

        vm.startPrank(address(nft));
        vm.expectRevert(abi.encodeWithSelector(NFTStaking.FailedToAddTokenIdToAccount.selector));
        nftStaking.onERC721Received(tokenIdOwner, tokenIdOwner, tokenId, "");
        vm.stopPrank();
    }

    function testClaimRewards() public {
        testStakeNFT();
        uint256 tokenId = nft.currentTokenId();
        (address tokenIdOwner, uint256 lastClaimedTime) = nftStaking.tokenIdToNFTInfo(tokenId);
        // Wait for 1 day
        vm.warp(lastClaimedTime + 1 days);
        // Claim rewards
        vm.startPrank(tokenIdOwner);
        nftStaking.claim(tokenId);
        vm.stopPrank();
        // Can withdraw 10 ERC20 tokens every 24 hours.
        assert(rewardToken.balanceOf(tokenIdOwner) == 10e18);
    }

    // Revert when claiming rewards if caller is not the owner of the NFT
    function testClaimRewardsWillFailNotOwner() external {
        testStakeNFT();
        uint256 tokenId = nft.currentTokenId();
        (address tokenIdOwner,) = nftStaking.tokenIdToNFTInfo(tokenId);

        vm.startPrank(makeAddr("NotNFTOwner"));
        vm.expectRevert(abi.encodeWithSelector(NFTStaking.NotOwnerOfNFT.selector));
        nftStaking.claim(tokenId);
        vm.stopPrank();
    }

    function testWithdrawNFT() external {
        testStakeNFT();
        uint256 tokenId = nft.currentTokenId();
        (address tokenIdOwner,) = nftStaking.tokenIdToNFTInfo(tokenId);

        // Pass 1 day to get rewards
        vm.warp(block.timestamp + 1 days);
        uint256 beforeRewardTokenBalance = rewardToken.balanceOf(tokenIdOwner);

        vm.startPrank(tokenIdOwner);
        nftStaking.withdrawNFT(tokenId);
        vm.stopPrank();

        uint256 dailyRewardAmount = nftStaking.DAILY_REWARD_AMOUNT();
        uint256 afterRewardTokenBalance = rewardToken.balanceOf(tokenIdOwner);
        assert(afterRewardTokenBalance == beforeRewardTokenBalance + dailyRewardAmount);

        assert(nftStaking.getStakedTokenIds(tokenIdOwner).length == 0);
        assert(nft.ownerOf(tokenId) == tokenIdOwner);
    }

    // Revert when withdrawing NFT if caller is not the owner of the NFT
    function testWithdrawNFTWillFailNotOwner() external {
        testStakeNFT();
        uint256 tokenId = nft.currentTokenId();
        (address tokenIdOwner,) = nftStaking.tokenIdToNFTInfo(tokenId);

        vm.startPrank(makeAddr("NotNFTOwner"));
        vm.expectRevert(abi.encodeWithSelector(NFTStaking.NotOwnerOfNFT.selector));
        nftStaking.withdrawNFT(tokenId);
        vm.stopPrank();
    }

    // Revert when withdrawing NFT if failed
    function testWithdrawNFTWillFailFailed() external {
        vm.startPrank(address(0));
        vm.expectRevert(abi.encodeWithSelector(NFTStaking.FailedToRemoveTokenIdFromAccount.selector));
        nftStaking.withdrawNFT(111);
        vm.stopPrank();
    }
}
