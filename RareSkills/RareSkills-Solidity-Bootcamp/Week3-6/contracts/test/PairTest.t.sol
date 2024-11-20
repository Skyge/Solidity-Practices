// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {DeployFactory} from "../script/DeployFactory.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {UniswapV2OptimizedPair} from "../src/UniswapV2OptimizedPair.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {UniswapV2OptimizedFactory} from "../src/UniswapV2OptimizedFactory.sol";

contract PairTest is Test {
    UniswapV2OptimizedFactory internal factory;
    HelperConfig internal helperConfig;

    MockERC20 internal token0;
    MockERC20 internal token1;
    UniswapV2OptimizedPair internal pair;

    address internal alice;

    error UntrustedLender();
    error UntrustedLoanInitiator();

    function setUp() external {
        DeployFactory deployer = new DeployFactory();
        (factory, helperConfig) = deployer.run();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        token0 = MockERC20(config.token0);
        token1 = MockERC20(config.token1);
        // Create a pool of the token0 and token1
        pair = UniswapV2OptimizedPair(factory.createPair(address(token0), address(token1)));

        alice = makeAddr("alice");
        uint256 faucetAmount = 1000000e18;

        vm.startPrank(alice);
        // Get free tokens
        token0.mint(alice, faucetAmount);
        token1.mint(alice, faucetAmount);
        // Approve the tokens to the pair
        token0.approve(address(pair), faucetAmount);
        token1.approve(address(pair), faucetAmount);
        vm.stopPrank();
    }

    function mintWhenLiquidityIsZero() internal {
        vm.startPrank(alice);
        // Add liquidity to the pair at the first time
        uint256 amount0Desired = 10000e18;
        uint256 amount1Desired = 10000e18;
        uint256 amount0Min = 0;
        uint256 amount1Min = 0;
        address recipient = alice;
        uint256 deadline = block.timestamp + 1000;
        (uint256 amount0, uint256 amount1, uint256 liquidity) =
            pair.mint(amount0Desired, amount1Desired, amount0Min, amount1Min, recipient, deadline);
        assertEq(amount0, amount0Desired);
        assertEq(amount1, amount1Desired);
        // When the first time to add liquidity, will mint some LP tokens to the zero address
        uint256 minimumLiquidity = pair.MINIMUM_LIQUIDITY();
        assertEq(liquidity + minimumLiquidity, 10000e18);
        assertEq(pair.totalSupply(), liquidity + minimumLiquidity);
        vm.stopPrank();
    }

    function swap() internal {
        // Add liquidity to the pair
        mintWhenLiquidityIsZero();
        // Swap token0 to token1
        address tokenIn = address(token0);
        uint256 amountIn = 1000e18;
        address to = alice;
        uint256 deadline = block.timestamp + 1000;
        // Calculate the amount of token1 that will be received
        (uint112 beforeReserve0, uint112 beforeReserve1,) = pair.getReserves();

        uint256 amountOutMin = pair.getAmountOut(amountIn, beforeReserve0, beforeReserve1);
        vm.startPrank(alice);
        uint256 amountOut = pair.swap(tokenIn, amountIn, amountOutMin, to, deadline);

        (uint112 afterReserve0, uint112 afterReserve1,) = pair.getReserves();
        assertEq(afterReserve0, beforeReserve0 + amountIn);
        assertEq(afterReserve1, beforeReserve1 - amountOut);
    }

    function mintWhenLiquidityIsNotZero() internal {
        swap();
        // ADD the liquidity for the second time
        uint256 amount0Desired = 5000e18;
        // Calculate the amount of token1 that needs to be added
        (uint112 beforeReserve0, uint112 beforeReserve1,) = pair.getReserves();
        uint256 amount1Desired = pair.quote(amount0Desired, beforeReserve0, beforeReserve1);

        uint256 beforeTotalSupply = pair.totalSupply();

        vm.startPrank(alice);
        (uint256 amount0, uint256 amount1, uint256 liquidity) = pair.mint(
            amount0Desired,
            amount1Desired,
            amount0Desired * 98 / 100, // amount0Min, 2% slippage
            amount1Desired * 98 / 100, // amount1Min, 2% slippage
            alice, // recipient
            block.timestamp + 1000 // deadline
        );
        vm.stopPrank();
        // All tokens are added to the pair
        assertEq(amount0, amount0Desired);
        assertEq(amount1, amount1Desired);
        // Total supply increased
        uint256 afterTotalSupply = pair.totalSupply();
        assertEq(afterTotalSupply, beforeTotalSupply + liquidity);
        // The amount of token0 and token1 in the pair increased
        (uint112 afterReserve0, uint112 afterReserve1,) = pair.getReserves();
        assertEq(afterReserve0, beforeReserve0 + amount0Desired);
        assertEq(afterReserve1, beforeReserve1 + amount1Desired);
    }

    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata data)
        external
        returns (bytes32)
    {
        if (msg.sender != address(pair)) {
            revert UntrustedLender();
        }
        if (initiator != address(this)) {
            revert UntrustedLoanInitiator();
        }
        // Do something like arbitrage
        // Mint token as profits
        token0.mint(address(this), fee);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function flashLoan() internal {
        mintWhenLiquidityIsNotZero();

        // Before flashLoan, reserve0 and reserve1
        (uint112 beforeReserve0, uint112 beforeReserve1,) = pair.getReserves();

        uint256 flashLoanAmount = 1000e18;
        uint256 fee = pair.flashFee(address(token0), flashLoanAmount);
        uint256 repayAmount = flashLoanAmount + fee;
        token0.approve(address(pair), repayAmount);
        pair.flashLoan(IERC3156FlashBorrower(address(this)), address(token0), flashLoanAmount, "");
        // After flashLoan, reserve0 and reserve1
        (uint112 afterReserve0, uint112 afterReserve1,) = pair.getReserves();

        // The amount of flashLoan token, token0, should increase due to the fee
        assertEq(afterReserve0, beforeReserve0 + fee);
        // The amount of token1 should be the same
        assertEq(afterReserve1, beforeReserve1);
    }

    function testBurn() public {
        flashLoan();
        // Burn the LP tokens
        uint256 liquidity = pair.balanceOf(alice);
        uint256 amount0Min = 0;
        uint256 amount1Min = 0;

        vm.startPrank(alice);
        (uint256 amount0, uint256 amount1) = pair.burn(
            liquidity,
            amount0Min,
            amount1Min,
            alice, // to
            block.timestamp + 1000 // deadline
        );
        vm.stopPrank();
        assertGt(amount0, 0);
        assertGt(amount1, 0);

        // The amount of token0 and token1 in the pair decreased
        (uint112 afterReserve0, uint112 afterReserve1,) = pair.getReserves();
    }
}
