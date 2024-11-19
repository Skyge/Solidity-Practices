// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "forge-std/console.sol";

contract BurnLiquidWithRouter {
    /**
     *  BURN LIQUIDITY WITH ROUTER EXERCISE
     *
     *  The contract has an initial balance of 0.01 UNI-V2-LP tokens.
     *  Burn a position (remove liquidity) from USDC/ETH pool to this contract.
     *  The challenge is to use Uniswapv2 router to remove all the liquidity from the pool.
     *
     */
    address public immutable router;

    constructor(address _router) {
        router = _router;
    }

    function burnLiquidityWithRouter(address pool, address usdc, address weth, uint256 deadline) public {
        // your code start here
        // Approve the router to spend the LP tokens
        IERC20(pool).approve(router, type(uint256).max);

        // r0: usdc, r1: weth
        (uint256 r0, uint256 r1,) = IUniswapV2Pair(pool).getReserves();

        uint256 poolTotalSupply = IERC20(pool).totalSupply();

        uint256 selfBalance = IERC20(pool).balanceOf(address(this));

        // Remove all the liquidity from the pool
        IUniswapV2Router(router).removeLiquidity(
            usdc,
            weth,
            IERC20(pool).balanceOf(address(this)),
            selfBalance * r0 / poolTotalSupply,
            selfBalance * r1 / poolTotalSupply,
            address(this),
            deadline
        );
    }
}

interface IUniswapV2Router {
    /**
     *     tokenA: the address of tokenA, in our case, USDC.
     *     tokenB: the address of tokenB, in our case, WETH.
     *     liquidity: the amount of LP tokens to burn.
     *     amountAMin: the minimum amount of amountA to receive.
     *     amountBMin: the minimum amount of amountB to receive.
     *     to: recipient address to receive tokenA and tokenB.
     *     deadline: timestamp after which the transaction will revert.
     */
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
}
