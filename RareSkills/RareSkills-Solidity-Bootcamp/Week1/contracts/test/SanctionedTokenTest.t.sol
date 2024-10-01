// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {SanctionedToken} from "../src/SanctionedToken.sol";
import {DeploySanctionedToken} from "../script/DeploySanctionedToken.s.sol";

contract SanctionedTokenTest is Test {
    using SafeERC20 for IERC20;

    SanctionedToken public sanctionedToken;
    address internal alice = makeAddr("alice");
    address internal blacklistedSpender = makeAddr("blacklistedSpender");
    address internal blacklistedRecipient = makeAddr("blacklistedRecipient");

    function setUp() external {
        DeploySanctionedToken deployer = new DeploySanctionedToken();
        sanctionedToken = deployer.run();

        vm.startPrank(msg.sender);
        // Distribute tokens to Alice
        uint256 faucetAmount = 10000e18;
        sanctionedToken.transfer(alice, faucetAmount);
        // Distribute tokens to blacklisted accounts
        sanctionedToken.transfer(blacklistedSpender, faucetAmount);

        // Add blacklisted accounts: Spender and Recipient
        sanctionedToken._addToBlacklist(blacklistedSpender);
        sanctionedToken._addToBlacklist(blacklistedRecipient);
        vm.stopPrank();
    }

    // Normal account can send and receive tokens
    function testNormalAccountCanSendAndReceiveTokens() external {
        // Alice is not blacklisted
        assert(!sanctionedToken.blacklist(alice));
        // deployer is not blacklisted
        assert(!sanctionedToken.blacklist(msg.sender));

        // Alice sends tokens to deployer
        uint256 beforeAliceBalance = sanctionedToken.balanceOf(alice);
        uint256 beforeDeployerBalance = sanctionedToken.balanceOf(msg.sender);
        uint256 transferAmount = 123e18;
        vm.prank(alice);
        sanctionedToken.transfer(msg.sender, transferAmount);
        uint256 afterAliceBalance = sanctionedToken.balanceOf(alice);
        uint256 afterDeployerBalance = sanctionedToken.balanceOf(msg.sender);
        assertEq(afterAliceBalance, beforeAliceBalance - transferAmount);
        assertEq(afterDeployerBalance, beforeDeployerBalance + transferAmount);
    }

    // Blacklisted Spender can't send tokens
    function testBlacklistedSpenderSendTokenWillFail() external {
        // Spender accoount is blacklisted
        assert(sanctionedToken.blacklist(blacklistedSpender));
        // Alice is not blacklisted
        assert(!sanctionedToken.blacklist(alice));

        vm.prank(blacklistedSpender);
        vm.expectRevert(abi.encodeWithSelector(SanctionedToken.AccountIsBlacklisted.selector, blacklistedSpender));
        sanctionedToken.transfer(alice, 100);
    }

    // Blacklisted Recipient can't receive tokens
    function testBlacklistedRecipientReceiveTokenWillFail() external {
        // Recipient account is blacklisted
        assert(sanctionedToken.blacklist(blacklistedRecipient));
        // Alice is not blacklisted
        assert(!sanctionedToken.blacklist(alice));

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(SanctionedToken.AccountIsBlacklisted.selector, blacklistedRecipient));
        sanctionedToken.transfer(blacklistedRecipient, 100);
    }
}
