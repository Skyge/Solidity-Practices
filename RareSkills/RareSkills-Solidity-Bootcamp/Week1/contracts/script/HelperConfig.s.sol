// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {SanctionedToken} from "../src/SanctionedToken.sol";

abstract contract CodeConstants {
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script {
    struct NetworkConfig {
        address reserveToken;
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
        if (networkConfigs[chainId].reserveToken != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert("Chain ID not supported");
        }
    }

    function getOrCreateAnvilEthConfig() internal returns (NetworkConfig memory) {
        // If has already been set, return it
        if (localNetworkConfig.reserveToken != address(0)) {
            return localNetworkConfig;
        }

        vm.startBroadcast();
        SanctionedToken reserveToken = new SanctionedToken("Reserve Token", "RT");
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({reserveToken: address(reserveToken)});

        return localNetworkConfig;
    }
}
