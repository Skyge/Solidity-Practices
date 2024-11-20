// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {DeployFactory} from "../script/DeployFactory.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {IUniswapV2Pair} from "../src/interfaces/IUniswapV2Pair.sol";
import {Test, console2} from "forge-std/Test.sol";
import {UniswapV2OptimizedFactory} from "../src/UniswapV2OptimizedFactory.sol";

contract FactoryTest is Test {
    UniswapV2OptimizedFactory internal factory;
    HelperConfig internal helperConfig;

    address internal token0;
    address internal token1;

    function setUp() external {
        DeployFactory deployer = new DeployFactory();
        (factory, helperConfig) = deployer.run();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        token0 = config.token0;
        token1 = config.token1;
    }

    function testSetFeeTo() public {
        address feeToSetter = factory.feeToSetter();
        vm.startPrank(feeToSetter);
        address feeTo = makeAddr("newFeeTo");
        factory.setFeeTo(feeTo);
        assertEq(feeTo, factory.feeTo());
        vm.stopPrank();
    }

    function testCreatePair() public {
        // Do not have a pool of the token0 and token1
        assertTrue(factory.getPair(token0, token1) == address(0));
        // Create a pool of the token0 and token1
        address pair = factory.createPair(token0, token1);
        // New pool
        assertTrue(factory.getPair(token0, token1) == pair);
        assertTrue(IUniswapV2Pair(pair).token0() == token0);
        assertTrue(IUniswapV2Pair(pair).token1() == token1);
    }
}
