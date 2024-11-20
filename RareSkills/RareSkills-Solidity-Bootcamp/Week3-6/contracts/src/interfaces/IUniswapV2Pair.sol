// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function initialize(address, address) external;
    function mint(
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 amount0Min,
        uint256 amount1Min,
        address recipient,
        uint256 deadline
    ) external returns (uint256 amount0, uint256 amount1, uint256 liquidity);
}
