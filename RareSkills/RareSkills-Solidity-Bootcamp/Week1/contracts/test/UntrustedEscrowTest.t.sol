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
        uint256 beforeEscrowCounts = untrustedEscrow.escrowId();
        untrustedEscrow.deposit(alice, address(token1), depositAmount);
        uint256 afterEscrowCounts = untrustedEscrow.escrowId();
        // Should make a new escrow
        assertEq(beforeEscrowCounts + 1, afterEscrowCounts);
        vm.stopPrank();

        (address buyer, address seller, address token, uint256 amount, uint256 releaseTime, bool cliamed) =
            untrustedEscrow.escrows(beforeEscrowCounts);

        assertEq(buyer, msg.sender);
        assertEq(seller, alice);
        assertEq(token, address(token1));
        assertEq(amount, depositAmount);
        assertEq(releaseTime, block.timestamp + 3 days);
        assert(!cliamed);
    }

    function testWithdraw() external {
        vm.startPrank(msg.sender);
        token1.forceApprove(address(untrustedEscrow), type(uint256).max);
        uint256 depositAmount = 100e18;
        uint256 beforeEscrowCounts = untrustedEscrow.escrowId();
        untrustedEscrow.deposit(alice, address(token1), depositAmount);
        vm.stopPrank();

        (, address seller,,, uint256 releaseTime, bool cliamed) =
            untrustedEscrow.escrows(beforeEscrowCounts);

        // Increase the time to the release time
        vm.warp(releaseTime);
        // Withdraw the token from the untrusted escrow
        vm.startPrank(seller);
        untrustedEscrow.withdraw(beforeEscrowCounts);
        vm.stopPrank();

        (,,,,, cliamed) = untrustedEscrow.escrows(beforeEscrowCounts);
        assert(cliamed);
    }
}
