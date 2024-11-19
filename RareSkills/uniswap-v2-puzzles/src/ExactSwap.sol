// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

import "forge-std/console.sol";

contract ExactSwap {
    /**
     *  PERFORM AN SIMPLE SWAP WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 WETH.
     *  The challenge is to swap an exact amount of WETH for 1337 USDC token using the `swap` function
     *  from USDC/WETH pool.
     *
     */
    function performExactSwap(address pool, address weth, address usdc) public {
        /**
         *     swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data);
         *
         *     amount0Out: the amount of USDC to receive from swap.
         *     amount1Out: the amount of WETH to receive from swap.
         *     to: recipient address to receive the USDC tokens.
         *     data: leave it empty.
         */

        // your code start here
        // Get the reserves of the pool
        (uint256 usdcReserve, uint256 wethReserve,) = IUniswapV2Pair(pool).getReserves();

        // Calculate the amount of WETH to swap
        // Rounding up
        uint256 usdcAmountOut = 1337 * 10 ** 6;
        uint256 wethAmountIn = wethReserve * usdcAmountOut * 1000 / (usdcReserve - usdcAmountOut) / 997 + 1;

        // Transfer calculated WETH to the pool
        IERC20(weth).transfer(pool, wethAmountIn);

        // Swap WETH for USDC
        IUniswapV2Pair(pool).swap(usdcAmountOut, 0, address(this), "");
    }
}
