// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "solady/tokens/ERC20.sol";

contract UniswapV2OptimizedERC20 is ERC20 {
    /// @dev Returns the name of the token.
    function name() public view override returns (string memory) {
        return "Uniswap V2 Optimized";
    }

    /// @dev Returns the symbol of the token.
    function symbol() public view override returns (string memory) {
        return "UNI-V2-OPT";
    }
}
