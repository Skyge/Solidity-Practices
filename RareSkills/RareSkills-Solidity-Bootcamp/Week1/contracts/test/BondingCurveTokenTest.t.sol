// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BondingCurveToken} from "../src/BondingCurveToken.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {DeployBondingCurveToken} from "../script/DeployBondingCurveToken.s.sol";

contract BondingCurveTokenTest is Test {
    BondingCurveToken public bondingCurveToken;
    HelperConfig public helperConfig;
    IERC20 public reserveToken;

    function setUp() external {
        DeployBondingCurveToken deployer = new DeployBondingCurveToken();
        (bondingCurveToken, helperConfig) = deployer.run();
        reserveToken = IERC20(helperConfig.getConfig().reserveToken);
    }

    function testDeployFailed() external {
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken.ReverseTokenIsZeroAddress.selector));
        new BondingCurveToken("BondingCurveToken", "BCT", address(0));
    }

    function testBuyingToken() public {
        // Buy 100 tokens
        uint256 amount = 100;
        (uint256 calculatedTotalCost,) = bondingCurveToken.calculateBuyCost(amount);
        // Slippage is 3%
        uint256 maxCostAmount = calculatedTotalCost + calculatedTotalCost * 3 / 100;

        uint256 beforeBuyerTokenBalance = bondingCurveToken.balanceOf(msg.sender);
        uint256 beforeBuyerReserveTokenBalance = reserveToken.balanceOf(msg.sender);
        uint256 beforeReserveContractReserveTokenBalance = reserveToken.balanceOf(address(bondingCurveToken));
        vm.startPrank(msg.sender);
        // Approve the reserve token to the bonding curve token
        reserveToken.approve(address(bondingCurveToken), type(uint256).max);
        // Buy tokens
        uint256 actualCost = bondingCurveToken.buy(msg.sender, amount, maxCostAmount);
        vm.stopPrank();

        uint256 afterBuyerTokenBalance = bondingCurveToken.balanceOf(msg.sender);
        uint256 afterBuyerReserveTokenBalance = reserveToken.balanceOf(msg.sender);
        uint256 afterReserveContractReserveTokenBalance = reserveToken.balanceOf(address(bondingCurveToken));
        assertEq(afterBuyerTokenBalance - beforeBuyerTokenBalance, amount);
        assertEq(beforeBuyerReserveTokenBalance - afterBuyerReserveTokenBalance, actualCost);
        assertEq(afterReserveContractReserveTokenBalance - beforeReserveContractReserveTokenBalance, actualCost);
    }

    // Revert when buying if the amount is zero
    function testBuyingTokenWillFailIfBuyingAmountIsZero() public {
        vm.startPrank(msg.sender);
        // Approve the reserve token to the bonding curve token
        reserveToken.approve(address(bondingCurveToken), type(uint256).max);
        // Buy tokens
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken.BuyingAmountIsZero.selector));
        bondingCurveToken.buy(msg.sender, 0, 0);
        vm.stopPrank();
    }

    // Revert when buying if the total cost is greater than the max cost amount
    function testBuyingTokenWillFailIfSlippageExceeded() public {
        // Buy 100 tokens
        uint256 amount = 100;
        (uint256 calculatedTotalCost,) = bondingCurveToken.calculateBuyCost(amount);
        // Decrease the max cost amount to make the slippage exceeded
        uint256 maxCostAmount = calculatedTotalCost - 1;

        vm.startPrank(msg.sender);
        // Approve the reserve token to the bonding curve token
        reserveToken.approve(address(bondingCurveToken), type(uint256).max);
        // Buy tokens
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken.BuyingSlippageExceeded.selector));
        bondingCurveToken.buy(msg.sender, amount, maxCostAmount);
        vm.stopPrank();
    }

    // Revert when buying if the buyer has insufficient reserve token
    function testBuyingTokenWillFailIfInsufficientReserveAmount() public {
        // Buy 100 tokens
        uint256 amount = 100;
        (uint256 calculatedTotalCost,) = bondingCurveToken.calculateBuyCost(amount);
        uint256 currentReserveTokenBalance = reserveToken.balanceOf(msg.sender);

        vm.startPrank(msg.sender);
        // Decrease the reserve token balance of the buyer to make it insufficient
        reserveToken.transfer(makeAddr("anotherAccount"), currentReserveTokenBalance - calculatedTotalCost + 1);

        // Approve the reserve token to the bonding curve token
        reserveToken.approve(address(bondingCurveToken), type(uint256).max);
        // Buy tokens
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken.InsufficientReserveAmount.selector));
        bondingCurveToken.buy(msg.sender, amount, type(uint256).max);
        vm.stopPrank();
    }

    function testSellingToken() public {
        // Sell 100 tokens
        uint256 amount = 100;
        // Buy token at first
        vm.startPrank(msg.sender);
        reserveToken.approve(address(bondingCurveToken), type(uint256).max);
        // Ignore slippage at here
        bondingCurveToken.buy(msg.sender, amount, type(uint256).max);

        (uint256 calculatedReceived,) = bondingCurveToken.calculateSellReceived(amount);
        // Slippage is 3%
        uint256 minReceived = calculatedReceived - calculatedReceived * 3 / 100;
        uint256 beforeBuyerTokenBalance = bondingCurveToken.balanceOf(msg.sender);
        uint256 beforeBuyerReserveTokenBalance = reserveToken.balanceOf(msg.sender);
        uint256 beforeReserveContractReserveTokenBalance = reserveToken.balanceOf(address(bondingCurveToken));

        // Sell tokens
        uint256 actualReceivedAmount = bondingCurveToken.sell(msg.sender, amount, minReceived);
        vm.stopPrank();

        uint256 afterBuyerTokenBalance = bondingCurveToken.balanceOf(msg.sender);
        uint256 afterBuyerReserveTokenBalance = reserveToken.balanceOf(msg.sender);
        uint256 afterReserveContractReserveTokenBalance = reserveToken.balanceOf(address(bondingCurveToken));
        assertEq(beforeBuyerTokenBalance - afterBuyerTokenBalance, amount);
        assertEq(afterBuyerReserveTokenBalance - beforeBuyerReserveTokenBalance, actualReceivedAmount);
        assertEq(
            beforeReserveContractReserveTokenBalance - afterReserveContractReserveTokenBalance, actualReceivedAmount
        );
        // Cause of selling fee, the actual received amount is less than the calculated received amount
        assertLt(actualReceivedAmount, calculatedReceived);
    }

    // Revert when selling if the recipient is zero address
    function testSellingTokenWillFailIfRecipientIsZeroAddress() external {
        // Sell 100 tokens
        uint256 amount = 100;
        // Buy token at first
        vm.startPrank(msg.sender);
        reserveToken.approve(address(bondingCurveToken), type(uint256).max);
        // Ignore slippage at here
        bondingCurveToken.buy(msg.sender, amount, type(uint256).max);

        vm.startPrank(msg.sender);
        // Sell tokens
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken.RecipientIsZeroAddress.selector));
        bondingCurveToken.sell(address(0), amount, 0);
        vm.stopPrank();
    }

    // Revert when selling if the amount is zero
    function testSellingTokenWillFailIfSellingAmountIsZero() external {
        // Sell 0 tokens
        uint256 amount = 0;
        vm.startPrank(msg.sender);
        // Sell tokens
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken.SellingAmountIsZero.selector));
        bondingCurveToken.sell(msg.sender, amount, 0);
        vm.stopPrank();
    }

    // Revert when selling if the seller has insufficient token amount
    function testSellingTokenWillFailIfInsufficientTokenAmount() external {
        // Sell 100 tokens
        uint256 amount = 100;
        // Buy token at first
        vm.startPrank(msg.sender);
        reserveToken.approve(address(bondingCurveToken), type(uint256).max);
        // Ignore slippage at here
        bondingCurveToken.buy(msg.sender, amount, type(uint256).max);

        vm.startPrank(msg.sender);
        // Decrease the token balance of the seller to make it insufficient
        bondingCurveToken.transfer(makeAddr("anotherAccount"), amount - 1);
        // Sell tokens
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken.InsufficientTokenAmount.selector));
        bondingCurveToken.sell(msg.sender, amount, 0);
        vm.stopPrank();
    }

    // Revert when selling if the actual received amount is less than the min received amount
    function testSellingTokenWillFailIfSellingSlippageExceeded() external {
        // Sell 100 tokens
        uint256 amount = 100;
        // Buy token at first
        vm.startPrank(msg.sender);
        reserveToken.approve(address(bondingCurveToken), type(uint256).max);
        // Ignore slippage at here
        bondingCurveToken.buy(msg.sender, amount, type(uint256).max);

        (uint256 calculatedReceived,) = bondingCurveToken.calculateSellReceived(amount);
        // Increase the min received amount to make the slippage exceeded
        uint256 minReceived = calculatedReceived + 1;
        vm.startPrank(msg.sender);
        // Sell tokens
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken.SellingSlippageExceeded.selector));
        bondingCurveToken.sell(msg.sender, amount, minReceived);
        vm.stopPrank();
    }

    function testWithdrawReserves() public {
        // Buy 100 tokens
        uint256 amount = 100;
        // Buy tokens
        vm.startPrank(msg.sender);
        reserveToken.approve(address(bondingCurveToken), type(uint256).max);
        // Ignore slippage at here
        bondingCurveToken.buy(msg.sender, amount, type(uint256).max);
        // Sell tokens to get reserve token
        bondingCurveToken.sell(msg.sender, amount, 0);
        // Has reserves
        assertGt(reserveToken.balanceOf(address(bondingCurveToken)), 0);
        // Current `msg.sender` is the owner of the bonding curve token
        assertEq(bondingCurveToken.owner(), msg.sender);
        // Withdraw reserves
        address recipient = makeAddr("treasury");
        uint256 beforeRecipientReserveTokenBalance = reserveToken.balanceOf(recipient);
        uint256 reservesAmount = bondingCurveToken.reserves();
        bondingCurveToken._withdrawReserves(recipient);
        uint256 afterRecipientReserveTokenBalance = reserveToken.balanceOf(recipient);
        assertEq(afterRecipientReserveTokenBalance - beforeRecipientReserveTokenBalance, reservesAmount);
        vm.stopPrank();
    }

    function testGetTokenDecimals() external view {
        assertGt(bondingCurveToken.decimals(), 0);
    }
}
