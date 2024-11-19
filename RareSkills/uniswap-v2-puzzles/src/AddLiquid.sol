// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";

import "forge-std/console.sol";

contract AddLiquid {
    /**
     *  ADD LIQUIDITY WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1000 USDC and 1 WETH.
     *  Mint a position (deposit liquidity) in the pool USDC/WETH to msg.sender.
     *  The challenge is to provide the same ratio as the pool then call the mint function in the pool contract.
     *
     */
    function addLiquidity(address usdc, address weth, address pool, uint256 usdcReserve, uint256 wethReserve) public {
        IUniswapV2Pair pair = IUniswapV2Pair(pool);

        // your code start here

        // see available functions here: https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol

        // 1 WETH = ? USDC
        uint256 reserveRatio = usdcReserve * 10 ** 18 / wethReserve;

        uint256 selfWETHAmount = IUniswapV2Pair(weth).balanceOf(address(this));
        uint256 selfUSDCAmount = IUniswapV2Pair(usdc).balanceOf(address(this));
        uint256 selfRatio = selfUSDCAmount * 10 ** 18 / selfWETHAmount;
        
        uint256 expectedWethAmount;
        uint256 expectedUsdcAmount;

        if (reserveRatio >= selfRatio) {
            // Transfer all USDC to the pair
            expectedUsdcAmount = IUniswapV2Pair(usdc).balanceOf(address(this));
            // Calculate the amount of WETH to transfer
            expectedWethAmount = wethReserve * expectedUsdcAmount / usdcReserve;
        } else {
            // Transfer all WETH to the pair
            expectedWethAmount = IUniswapV2Pair(weth).balanceOf(address(this));
            // Calculate the amount of USDC to transfer
            expectedUsdcAmount = usdcReserve * expectedWethAmount / wethReserve;
        }

        IUniswapV2Pair(weth).transfer(address(pair), expectedWethAmount);
        IUniswapV2Pair(usdc).transfer(address(pair), expectedUsdcAmount);

        pair.mint(msg.sender);
    }
}
