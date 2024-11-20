// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {UniswapV2OptimizedFactory} from "../src/UniswapV2OptimizedFactory.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFactory is Script {
    function run() external returns (UniswapV2OptimizedFactory, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast();
        UniswapV2OptimizedFactory factory = new UniswapV2OptimizedFactory(config.feeToSetter);
        vm.stopBroadcast();

        return (factory, helperConfig);
    }
}
