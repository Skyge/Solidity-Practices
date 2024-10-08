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
    }

    /*//////////////////////////////////////////////////////////////
                           MyNFT Tests
    //////////////////////////////////////////////////////////////*/
    function testNormalMint() external {
        uint256 beforeTokenId = nft.currentTokenId();
        vm.prank(alice);
        nft.safeMint{value: 0.1 ether}(alice);
        assert(nft.ownerOf(beforeTokenId) == alice);
        assert(nft.currentTokenId() == beforeTokenId + 1);
        assert(nft.balanceOf(alice) == 1);
        assert(address(nft).balance == 0.1 ether);
    }

    function testMintWithDiscount() external {
        vm.deal(discountAccount1, 1000 ether);

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
        assert(nft.ownerOf(beforeTokenId) == discountAccount1);
        assert(nft.currentTokenId() == beforeTokenId + 1);
        assert(nft.balanceOf(discountAccount1) == 1);
        assert(address(nft).balance == 0.08 ether);
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

    /*//////////////////////////////////////////////////////////////
                           NFTStaking Tests
    //////////////////////////////////////////////////////////////*/
    function testStakeNFT() public {
        uint256 tokenId = nft.currentTokenId();
        vm.startPrank(alice);
        nft.safeMint{value: 0.1 ether}(alice);
        // Transfer NFT to NFTStaking to stake
        nft.safeTransferFrom(alice, address(nftStaking), tokenId);
        vm.stopPrank();

        (address tokenIdOwner,) = nftStaking.tokenIdToNFTInfo(tokenId);
        assert(tokenIdOwner == alice);
        assert(nftStaking.getStakedTokenIds(alice).length == 1);
    }

    function testClaimRewards() public {
        testStakeNFT();
        uint256 lastTokenId = nft.currentTokenId() - 1;
        (address tokenIdOwner, uint256 lastClaimedTime) = nftStaking.tokenIdToNFTInfo(lastTokenId);
        // Wait for 1 day
        vm.warp(lastClaimedTime + 1 days);
        // Claim rewards
        vm.startPrank(tokenIdOwner);
        nftStaking.claim(lastTokenId);
        vm.stopPrank();
        // Can withdraw 10 ERC20 tokens every 24 hours.
        assert(rewardToken.balanceOf(tokenIdOwner) == 10e18);
    }

    function testWithdrawNFT() external {
        testClaimRewards();
        uint256 lastTokenId = nft.currentTokenId() - 1;
        (address tokenIdOwner,) = nftStaking.tokenIdToNFTInfo(lastTokenId);

        vm.startPrank(tokenIdOwner);
        nftStaking.withNFT(lastTokenId);
        vm.stopPrank();

        assert(nftStaking.getStakedTokenIds(tokenIdOwner).length == 0);
        assert(nft.ownerOf(lastTokenId) == tokenIdOwner);
    }
}
