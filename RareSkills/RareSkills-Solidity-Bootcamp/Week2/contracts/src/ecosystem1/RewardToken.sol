// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Reward Token Contract
 * @author Skyge
 * @dev This contract is used to create a reward token. The token can only be minted by the miner.
 */
contract RewardToken is AccessControl, ERC20 {
    bytes32 public constant MINER_ROLE = keccak256("MINER_ROLE");

    /*//////////////////////////////////////////////////////////////
                           Constructor
    //////////////////////////////////////////////////////////////*/
    constructor() ERC20("Reward Token", "RWT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                           External function
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Only the miner can mint new token
     * @dev Mint the token to the specified address
     * @param to The address to receive the minted token
     * @param amount The amount of token to mint
     */
    function mint(address to, uint256 amount) external onlyRole(MINER_ROLE) {
        _mint(to, amount);
    }
}
