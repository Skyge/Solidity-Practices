// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IUniswapV2Factory {
    function feeTo() external view returns (address);
}
