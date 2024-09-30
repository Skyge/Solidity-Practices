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

        // Approve the bonding curve token to the reserve token
        bondingCurveToken.approve(address(reserveToken), type(uint256).max);
        // Sell tokens
        uint256 actualReceivedAmonut = bondingCurveToken.sell(msg.sender, amount, minReceived);
        vm.stopPrank();

        uint256 afterBuyerTokenBalance = bondingCurveToken.balanceOf(msg.sender);
        uint256 afterBuyerReserveTokenBalance = reserveToken.balanceOf(msg.sender);
        uint256 afterReserveContractReserveTokenBalance = reserveToken.balanceOf(address(bondingCurveToken));
        assertEq(beforeBuyerTokenBalance - afterBuyerTokenBalance, amount);
        assertEq(afterBuyerReserveTokenBalance - beforeBuyerReserveTokenBalance, actualReceivedAmonut);
        assertEq(
            beforeReserveContractReserveTokenBalance - afterReserveContractReserveTokenBalance, actualReceivedAmonut
        );
        // Cause of selling fee, the actual received amount is less than the calculated received amount
        assertLt(actualReceivedAmonut, calculatedReceived);
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
}
