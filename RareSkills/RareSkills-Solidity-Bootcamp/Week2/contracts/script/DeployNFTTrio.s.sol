// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {MyNFT} from "../src/ecosystem1/MyNFT.sol";
import {RewardToken} from "../src/ecosystem1/RewardToken.sol";
import {NFTStaking} from "../src/ecosystem1/NFTStaking.sol";

contract DeployNFTTrio is Script {
    function run() external returns (RewardToken, MyNFT, NFTStaking, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast();
        // Deploy reward token
        RewardToken rewardToken = new RewardToken();
        // Deploy NFT
        MyNFT nft = new MyNFT(config.feeRecipient, config.merkleRoot);
        // Deploy NFT staking
        NFTStaking nftStaking = new NFTStaking(address(nft), address(rewardToken));
        // Set NFT staking as the minter of reward token
        rewardToken.grantRole(rewardToken.MINER_ROLE(), address(nftStaking));
        vm.stopBroadcast();

        return (rewardToken, nft, nftStaking, helperConfig);
    }
}
