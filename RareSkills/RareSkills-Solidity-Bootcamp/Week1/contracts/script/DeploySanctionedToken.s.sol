// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {SanctionedToken} from "../src/SanctionedToken.sol";

contract DeploySanctionedToken is Script {
    function run() external returns (SanctionedToken) {
        vm.startBroadcast();
        SanctionedToken sanctionedToken = new SanctionedToken("Sanctioned Token", "ST");
        vm.stopBroadcast();

        return (sanctionedToken);
    }
}
