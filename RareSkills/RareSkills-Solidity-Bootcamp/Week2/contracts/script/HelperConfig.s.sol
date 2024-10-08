// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";

abstract contract CodeConstants {
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script {
    struct NetworkConfig {
        address feeRecipient;
        bytes32 merkleRoot;
        address discountAccount1;
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
        if (networkConfigs[chainId].feeRecipient != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert("Chain ID not supported");
        }
    }

    function getOrCreateAnvilEthConfig() internal returns (NetworkConfig memory) {
        // If has already been set, return it
        if (localNetworkConfig.feeRecipient != address(0)) {
            return localNetworkConfig;
        }

        localNetworkConfig = NetworkConfig({
            feeRecipient: makeAddr("treasury"),
            merkleRoot: 0x58f8e12b6ea87c29254f6b9f8e845f086aefa9f69b59b337ac9fe40fd8d1e9da,
            discountAccount1: 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720
        });

        return localNetworkConfig;
    }
}
