// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {BondingCurveToken} from "../src/BondingCurveToken.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployBondingCurveToken is Script {
    function run() external returns (BondingCurveToken, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast();
        BondingCurveToken bondingCurveToken = new BondingCurveToken("Bonding Curve Token", "BCT", config.reserveToken);
        vm.stopBroadcast();

        return (bondingCurveToken, helperConfig);
    }
}
