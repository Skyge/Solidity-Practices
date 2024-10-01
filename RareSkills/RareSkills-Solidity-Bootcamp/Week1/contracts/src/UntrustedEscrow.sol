// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Untrusted Escrow
 * @author Skyge
 * @notice Can handle fee-on transfer tokens and non-standard ERC20 tokens
 * @dev An escrow contract that a buyer can put an arbitrary ERC20 token into a contract
 *      and a seller can withdraw it 3 days later.
 */
contract UntrustedEscrow {
    using SafeERC20 for IERC20;

    struct EscrowInfo {
        address buyer;
        address seller;
        address token;
        uint256 amount;
        uint256 releaseTime;
        bool cliamed;
    }

    mapping(uint256 escrowId => EscrowInfo escrowInfo) public escrows;
    // The escrow id
    uint256 public escrowId;

    event EscrowDeposited(uint256 indexed escrowId);
    event EscrowWithdrawn(uint256 indexed escrowId);

    error SellerIsZeroAddress();
    error TokenIsZeroAddress();
    error AmountIsZero();
    error WithdrawalNotAllowedYet();
    error UnauthorizedWithdrawal();
    error HasClaimed();

    /**
     * @dev Deposit an arbitrary ERC20 token into the contract
     * @param seller The address of the seller that can withdraw the token later
     * @param token The address of the token to deposit
     * @param amount The amount of the token to deposit
     */
    function deposit(address seller, address token, uint256 amount) external {
        if (seller == address(0)) revert SellerIsZeroAddress();
        if (token == address(0)) revert TokenIsZeroAddress();
        if (amount == 0) revert AmountIsZero();

        uint256 currentBalance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        uint256 newBalance = IERC20(token).balanceOf(address(this));
        uint256 actualAmount = newBalance - currentBalance;

        escrows[escrowId] = EscrowInfo({
            buyer: msg.sender,
            seller: seller,
            token: token,
            amount: actualAmount,
            releaseTime: block.timestamp + 3 days,
            cliamed: false
        });

        emit EscrowDeposited(escrowId);
        escrowId++;
    }

    /**
     * @notice The withdrawal delay should passed,
     *         and the escrow should not be claimed yet,
     *         and only the seller can withdraw the token
     * @dev Withdraw the deposited token
     * @param escrowIdToWithdraw The id of the escrow to withdraw
     */
    function withdraw(uint256 escrowIdToWithdraw) external {
        EscrowInfo storage escrow = escrows[escrowIdToWithdraw];

        if (block.timestamp < escrow.releaseTime) revert WithdrawalNotAllowedYet();
        if (msg.sender != escrow.seller) revert UnauthorizedWithdrawal();
        if (escrow.cliamed) revert HasClaimed();

        escrow.cliamed = true;
        IERC20(escrow.token).safeTransfer(msg.sender, escrow.amount);

        emit EscrowWithdrawn(escrowIdToWithdraw);
    }
}
