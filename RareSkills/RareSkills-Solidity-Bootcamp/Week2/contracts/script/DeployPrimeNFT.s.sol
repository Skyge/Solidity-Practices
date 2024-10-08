// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {PrimeNFT} from "../src/ecosystem2/PrimeNFT.sol";

contract DeployPrimeNFT is Script {
    function run() external returns (PrimeNFT) {
        vm.startBroadcast();
        PrimeNFT primeNFT = new PrimeNFT();
        vm.stopBroadcast();

        return primeNFT;
    }
}
