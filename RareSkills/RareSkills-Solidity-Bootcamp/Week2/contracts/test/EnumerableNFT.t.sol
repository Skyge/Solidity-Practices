// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {EnumerableNFT} from "../src/ecosystem2/EnumerableNFT.sol";
import {DeployEnumerableNFT} from "../script/DeployEnumerableNFT.s.sol";

contract EnumerableNFTTest is Test {
    EnumerableNFT private enumerableNFT;
    address private alice = makeAddr("Alice");
    address private bob = makeAddr("Bob");

    function setUp() external {
        DeployEnumerableNFT deployer = new DeployEnumerableNFT();
        enumerableNFT = deployer.run();

        vm.deal(alice, 1000 ether);
        vm.deal(bob, 1000 ether);
    }

    function testMint() external {
        // Alice mints token with id [1,2,5], Bob mints token with id [3,4]
        vm.startPrank(alice);
        // Mint token with id 1
        enumerableNFT.safeMint(alice);
        // Mint token with id 2
        enumerableNFT.safeMint(alice);
        vm.stopPrank();

        vm.startPrank(bob);
        // Mint token with id 3
        enumerableNFT.safeMint(bob);
        // Mint token with id 4
        enumerableNFT.safeMint(bob);
        vm.stopPrank();

        // Alice mints token with id 5
        vm.startPrank(alice);
        enumerableNFT.safeMint(alice);
        vm.stopPrank();

        // Alice has 3 tokens
        assertEq(enumerableNFT.balanceOf(alice), 3);
        // Bob has 2 tokens
        assertEq(enumerableNFT.balanceOf(bob), 2);

        // Alice's token with index 0 is 1
        assertEq(enumerableNFT.tokenOfOwnerByIndex(alice, 0), 1);
        // Alice's token with index 1 is 2
        assertEq(enumerableNFT.tokenOfOwnerByIndex(alice, 1), 2);
        // Alice's token with index 2 is 5
        assertEq(enumerableNFT.tokenOfOwnerByIndex(alice, 2), 5);

        // Bob's token with index 0 is 3
        assertEq(enumerableNFT.tokenOfOwnerByIndex(bob, 0), 3);
        // Bob's token with index 1 is 4
        assertEq(enumerableNFT.tokenOfOwnerByIndex(bob, 1), 4);
    }
}
