// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title Sanctioned Token
 * @author Skyge
 * @notice Owner can blacklist accounts so that they can't send and receive tokens anymore.
 */
contract SanctionedToken is Ownable2Step, ERC20 {
    // Store the blacklisted status of an account
    mapping(address _account => bool blacklisted) public blacklist;

    event BlacklistedAccountAdded(address addr);
    event BlacklistedAccountRemoved(address addr);

    error AccountIsAlreadyBlacklisted();
    error AccountIsNotBlacklisted();
    error AccountIsBlacklisted(address account);

    /*//////////////////////////////////////////////////////////////
                           Constructor
    //////////////////////////////////////////////////////////////*/
    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(msg.sender) {
        _mint(msg.sender, 21_000_000 * 10 ** 18);
    }

    /*//////////////////////////////////////////////////////////////
                           Owner functions
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Only owner can call this function
     * @dev Add an account to the blacklist
     * @param account The account to be added to the blacklist
     */
    function _addToBlacklist(address account) public onlyOwner {
        if (blacklist[account]) {
            revert AccountIsAlreadyBlacklisted();
        }

        blacklist[account] = true;
        emit BlacklistedAccountAdded(account);
    }

    /**
     * @notice Only owner can call this function
     * @dev Remove an account from the blacklist
     * @param account The account to be removed from the blacklist
     */
    function _removeFromBlacklist(address account) public onlyOwner {
        if (!blacklist[account]) {
            revert AccountIsNotBlacklisted();
        }

        blacklist[account] = false;
        emit BlacklistedAccountRemoved(account);
    }

    /*//////////////////////////////////////////////////////////////
                           Internal functions
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Overrided internal function to check if the account is blacklisted
     */
    function _update(address from, address to, uint256 value) internal virtual override {
        if (blacklist[from]) {
            revert AccountIsBlacklisted(from);
        }

        if (blacklist[to]) {
            revert AccountIsBlacklisted(to);
        }

        super._update(from, to, value);
    }
}
