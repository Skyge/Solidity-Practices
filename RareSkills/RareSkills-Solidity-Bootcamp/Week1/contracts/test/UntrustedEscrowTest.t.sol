// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {SanctionedToken} from "../src/SanctionedToken.sol";
import {UntrustedEscrow} from "../src/UntrustedEscrow.sol";
import {DeployUntrustedEscrow} from "../script/DeployUntrustedEscrow.s.sol";

contract UntrustedEscrowTest is Test {
    using SafeERC20 for IERC20;

    UntrustedEscrow public untrustedEscrow;
    IERC20 public token1;

    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");

    function setUp() external {
        DeployUntrustedEscrow deployer = new DeployUntrustedEscrow();
        untrustedEscrow = deployer.run();

        vm.startPrank(msg.sender);
        // Deploy a token
        token1 = IERC20(address(new SanctionedToken("Sanctioned Token", "ST")));
        vm.stopPrank();
    }

    function testDeposit() external {
        vm.startPrank(msg.sender);
        // Approve the token to the untrusted escrow to deposit
        token1.forceApprove(address(untrustedEscrow), type(uint256).max);
        // Deposit the token to the untrusted escrow
        uint256 depositAmount = 100e18;
        uint256 beforeEscrowCounts = untrustedEscrow.escrowCounts();
        untrustedEscrow.deposit(alice, address(token1), depositAmount);
        uint256 afterEscrowCounts = untrustedEscrow.escrowCounts();
        // Should make a new escrow
        assertEq(beforeEscrowCounts + 1, afterEscrowCounts);
        vm.stopPrank();

        (address buyer, address seller, address token, uint256 amount, uint256 releaseTime, bool claimed) =
            untrustedEscrow.escrows(beforeEscrowCounts);

        assertEq(buyer, msg.sender);
        assertEq(seller, alice);
        assertEq(token, address(token1));
        assertEq(amount, depositAmount);
        assertEq(releaseTime, block.timestamp + 3 days);
        assert(!claimed);
    }

    // Revert when depositing if the seller is the zero address
    function testDepositRevertIfSellerIsZeroAddress() external {
        vm.startPrank(msg.sender);
        token1.forceApprove(address(untrustedEscrow), type(uint256).max);
        vm.expectRevert(abi.encodeWithSelector(UntrustedEscrow.SellerIsZeroAddress.selector));
        untrustedEscrow.deposit(address(0), address(token1), 100e18);
        vm.stopPrank();
    }

    // Revert when depositing if the token is the zero address
    function testDepositRevertIfTokenIsZeroAddress() external {
        vm.startPrank(msg.sender);
        token1.forceApprove(address(untrustedEscrow), type(uint256).max);
        vm.expectRevert(abi.encodeWithSelector(UntrustedEscrow.TokenIsZeroAddress.selector));
        untrustedEscrow.deposit(alice, address(0), 100e18);
        vm.stopPrank();
    }

    // Revert when depositing if the amount is zero
    function testDepositRevertIfAmountIsZero() external {
        vm.startPrank(msg.sender);
        token1.forceApprove(address(untrustedEscrow), type(uint256).max);
        vm.expectRevert(abi.encodeWithSelector(UntrustedEscrow.AmountIsZero.selector));
        untrustedEscrow.deposit(alice, address(token1), 0);
        vm.stopPrank();
    }

    function testWithdraw() external {
        vm.startPrank(msg.sender);
        token1.forceApprove(address(untrustedEscrow), type(uint256).max);
        uint256 depositAmount = 100e18;
        uint256 beforeEscrowCounts = untrustedEscrow.escrowCounts();
        untrustedEscrow.deposit(alice, address(token1), depositAmount);
        vm.stopPrank();

        (, address seller,,, uint256 releaseTime, bool claimed) = untrustedEscrow.escrows(beforeEscrowCounts);

        // Increase the time to the release time
        vm.warp(releaseTime);
        // Withdraw the token from the untrusted escrow
        vm.startPrank(seller);
        untrustedEscrow.withdraw(beforeEscrowCounts);
        vm.stopPrank();

        (,,,,, claimed) = untrustedEscrow.escrows(beforeEscrowCounts);
        assert(claimed);
    }

    // Revert when withdrawing if the escrow does not be allowed to withdraw
    function testWithdrawRevertIfNotAllowed() external {
        uint256 beforeEscrowCounts = untrustedEscrow.escrowCounts();
        vm.startPrank(msg.sender);
        token1.forceApprove(address(untrustedEscrow), type(uint256).max);
        untrustedEscrow.deposit(alice, address(token1), 100e18);
        vm.stopPrank();

        (,,,, uint256 releaseTime,) = untrustedEscrow.escrows(beforeEscrowCounts);
        // Increase the time, but does reach the release time
        vm.warp(releaseTime - 1);
        console2.log("current time", block.timestamp, "release time", releaseTime);
        // Withdraw the token from the untrusted escrow
        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(UntrustedEscrow.WithdrawalNotAllowedYet.selector));
        untrustedEscrow.withdraw(beforeEscrowCounts);
        vm.stopPrank();
    }

    // Revert when withdrawing if the call is unauthorized withdrawal
    function testWithdrawRevertIfUnauthorizedWithdrawal() external {
        uint256 beforeEscrowCounts = untrustedEscrow.escrowCounts();
        vm.startPrank(msg.sender);
        token1.forceApprove(address(untrustedEscrow), type(uint256).max);
        untrustedEscrow.deposit(alice, address(token1), 100e18);
        vm.stopPrank();

        (, address seller,,, uint256 releaseTime,) = untrustedEscrow.escrows(beforeEscrowCounts);
        // Increase the time to the release time
        vm.warp(releaseTime);
        // Bob is not the seller
        assertTrue(bob != seller);
        // Withdraw the token from the untrusted escrow
        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSelector(UntrustedEscrow.UnauthorizedWithdrawal.selector));
        untrustedEscrow.withdraw(beforeEscrowCounts);
        vm.stopPrank();
    }

    // Revert when withdrawing if the escrow has been claimed
    function testWithdrawRevertIfEscrowClaimed() external {
        uint256 beforeEscrowCounts = untrustedEscrow.escrowCounts();
        vm.startPrank(msg.sender);
        token1.forceApprove(address(untrustedEscrow), type(uint256).max);
        untrustedEscrow.deposit(alice, address(token1), 100e18);
        vm.stopPrank();

        (,,,, uint256 releaseTime,) = untrustedEscrow.escrows(beforeEscrowCounts);
        // Increase the time to the release time
        vm.warp(releaseTime);
        // Withdraw the token from the untrusted escrow
        vm.startPrank(alice);
        untrustedEscrow.withdraw(beforeEscrowCounts);
        vm.stopPrank();

        // Withdraw the token from the untrusted escrow again
        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(UntrustedEscrow.HasClaimed.selector));
        untrustedEscrow.withdraw(beforeEscrowCounts);
        vm.stopPrank();
    }
}
