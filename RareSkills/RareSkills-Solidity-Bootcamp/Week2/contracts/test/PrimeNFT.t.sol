// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {PrimeNFT} from "../src/ecosystem2/PrimeNFT.sol";
import {DeployPrimeNFT} from "../script/DeployPrimeNFT.s.sol";

contract PrimeNFTTest is Test {
    PrimeNFT private primeNFT;
    address private alice = makeAddr("Alice");
    address private bob = makeAddr("Bob");

    function setUp() external {
        DeployPrimeNFT deployer = new DeployPrimeNFT();
        primeNFT = deployer.run();

        vm.deal(alice, 1000 ether);
        vm.deal(bob, 1000 ether);
    }

    function testMint() external {
        // Alice mints token with id [1,2,5], Bob mints token with id [3,4]
        vm.startPrank(alice);
        // Mint token with id 1
        primeNFT.safeMint(alice);
        // Mint token with id 2
        primeNFT.safeMint(alice);
        vm.stopPrank();

        vm.startPrank(bob);
        // Mint token with id 3
        primeNFT.safeMint(bob);
        // Mint token with id 4
        primeNFT.safeMint(bob);
        vm.stopPrank();

        // Alice mints token with id 5
        vm.startPrank(alice);
        primeNFT.safeMint(alice);
        vm.stopPrank();

        // Alice has 3 tokens
        assertEq(primeNFT.balanceOf(alice), 3);
        // Bob has 2 tokens
        assertEq(primeNFT.balanceOf(bob), 2);

        // Alice has 2 prime tokens: 2,5
        assertEq(primeNFT.primeIdCounts(alice), 2);
        // Bob has 0 prime tokens: 3
        assertEq(primeNFT.primeIdCounts(bob), 1);
    }
}
