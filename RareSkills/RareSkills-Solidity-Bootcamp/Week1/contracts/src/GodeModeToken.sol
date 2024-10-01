// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title Gode Mode Token
 * @author Skyge
 * @notice A special address is able to transfer tokens between addresses at will.
 * @dev This contract is an ERC20 token with a special address that can transfer tokens between addresses at will.
 */
contract GodeModeToken is Ownable2Step, ERC20 {
    // Special address that can transfer tokens between addresses at will
    address public god;

    event TransferByGod(address indexed from, address indexed to, uint256 value);
    error NotGod();

    /*//////////////////////////////////////////////////////////////
                           Constructor
    //////////////////////////////////////////////////////////////*/
    constructor() ERC20("Gode Mode Token", "GMT") Ownable(msg.sender) {}

    /*//////////////////////////////////////////////////////////////
                           God functions
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Only god can call this function
     * @dev Transfer tokens between addresses at will by god
     * @param from The address to transfer tokens from
     * @param to The address to transfer tokens to
     * @param value The amount of tokens to transfer
     */
    function transferByGod(address from, address to, uint256 value) external {
        if (msg.sender != god) {
            revert NotGod();
        }

        _update(from, to, value);

        emit TransferByGod(from, to, value);
    }

    /*//////////////////////////////////////////////////////////////
                           Owner functions
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Only owner can call this function
     * @dev Mint new tokens
     * @param to The address to receive the minted tokens
     * @param value The amount of tokens to mint
     */
    function mint(address to, uint256 value) public onlyOwner {
        _mint(to, value);
    }
}
