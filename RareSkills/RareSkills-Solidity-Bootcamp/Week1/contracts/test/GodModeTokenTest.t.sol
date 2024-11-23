// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {GodModeToken} from "../src/GodModeToken.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {DeployGodModeToken} from "../script/DeployGodModeToken.s.sol";

contract GodModeTokenTest is Test {
    GodModeToken public godModeToken;
    HelperConfig public helperConfig;
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");

    function setUp() external {
        DeployGodModeToken deployer = new DeployGodModeToken();
        (godModeToken, helperConfig) = deployer.run();
    }

    function testDeployFailed() external {
        // Deploy failed
        vm.expectRevert(abi.encodeWithSelector(GodModeToken.GodAddressIsZeroAddress.selector));
        new GodModeToken(address(0));
    }

    // Transfer tokens by god
    function testTransferTokensByGod() external {
        // Mint 100 tokens
        uint256 amount = 100e18;
        vm.startPrank(godModeToken.owner());
        godModeToken.mint(alice, amount);
        vm.stopPrank();

        // Alice has tokens
        assertTrue(godModeToken.balanceOf(alice) > 0);

        uint256 beforeAliceTokenBalance = godModeToken.balanceOf(alice);
        uint256 beforeBobTokenBalance = godModeToken.balanceOf(bob);

        // Transfer 50 tokens from alice to bob by god
        vm.startPrank(godModeToken.god());
        godModeToken.transferByGod(alice, bob, 50e18);
        vm.stopPrank();

        uint256 afterAliceTokenBalance = godModeToken.balanceOf(alice);
        uint256 afterBobTokenBalance = godModeToken.balanceOf(bob);
        assertEq(beforeAliceTokenBalance - afterAliceTokenBalance, 50e18);
        assertEq(afterBobTokenBalance - beforeBobTokenBalance, 50e18);
    }

    // Revert when transfer tokens by non-god
    function testRevertTransferTokensByNonGod() external {
        // Mint 100 tokens
        uint256 amount = 100e18;
        vm.startPrank(godModeToken.owner());
        godModeToken.mint(alice, amount);
        vm.stopPrank();

        // Alice has tokens
        assertTrue(godModeToken.balanceOf(alice) > 0);
        // Alice is not the god
        assertTrue(alice != godModeToken.god());

        // Transfer 50 tokens from alice to bob by alice
        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(GodModeToken.NotGod.selector));
        godModeToken.transferByGod(alice, bob, 50e18);
        vm.stopPrank();
    }

    // Mint tokens by owner
    function testMintTokensByOwner() external {
        // Mint 100 tokens
        uint256 amount = 100e18;
        uint256 beforeMintedTokenBalance = godModeToken.balanceOf(alice);

        // Mint tokens to alice
        vm.startPrank(godModeToken.owner());
        godModeToken.mint(alice, amount);
        vm.stopPrank();

        uint256 afterMintedTokenBalance = godModeToken.balanceOf(alice);
        assertEq(afterMintedTokenBalance - beforeMintedTokenBalance, amount);
    }

    // Revert when minting tokens by non-owner
    function testRevertMintTokensByNonOwner() external {
        // Mint 100 tokens
        uint256 amount = 100e18;
        // Alice is not the owner
        assertTrue(alice != godModeToken.owner());
        vm.startPrank(alice);
        vm.expectRevert();
        godModeToken.mint(alice, amount);
        vm.stopPrank();
    }
}
