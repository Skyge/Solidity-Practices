// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {GodModeToken} from "../src/GodModeToken.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployGodModeToken is Script {
    function run() external returns (GodModeToken, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast();
        GodModeToken godModeToken = new GodModeToken(config.godAddress);
        vm.stopBroadcast();

        return (godModeToken, helperConfig);
    }
}
