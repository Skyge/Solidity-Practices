// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {EnumerableNFT} from "../src/ecosystem2/EnumerableNFT.sol";

contract DeployEnumerableNFT is Script {
    function run() external returns (EnumerableNFT) {
        vm.startBroadcast();
        EnumerableNFT enumerableNFT = new EnumerableNFT();
        vm.stopBroadcast();

        return enumerableNFT;
    }
}
