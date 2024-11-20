// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";

abstract contract CodeConstants {
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script {
    address public FOUNDRY_DEFAULT_SENDER = 0x9f7cF1d1F558E57ef88a59ac3D47214eF25B6A06;

    struct NetworkConfig {
        address feeToSetter;
        address token0;
        address token1;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        // Note: Skip doing the local config
        // networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
        // networkConfigs[ETH_MAINNET_CHAIN_ID] = getMainnetEthConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].feeToSetter != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert("Chain ID not supported");
        }
    }

    function getOrCreateAnvilEthConfig() internal returns (NetworkConfig memory) {
        // If has already been set, return it
        if (localNetworkConfig.feeToSetter != address(0)) {
            return localNetworkConfig;
        }

        address mockToken0 = address(new MockERC20());
        address mockToken1 = address(new MockERC20());
        // Sort the tokens
        (mockToken0, mockToken1) = mockToken0 < mockToken1 ? (mockToken0, mockToken1) : (mockToken1, mockToken0);

        localNetworkConfig =
            NetworkConfig({feeToSetter: FOUNDRY_DEFAULT_SENDER, token0: mockToken0, token1: mockToken1});

        return localNetworkConfig;
    }
}
