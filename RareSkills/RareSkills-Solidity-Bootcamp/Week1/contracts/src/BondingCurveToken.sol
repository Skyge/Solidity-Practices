// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Bonding Curve Token
 * @author Skyge
 * @notice Use a linear bonding curve, and charge a fee when selling token, the fee is 0.05%,
 *         And the decimals of the token is the same as the reserve token.
 *         And do not support the reserve token that has a fee when transfer.
 * @dev This contract is used to create a bonding curve token,
 *      which can be used to buy and sell tokens.
 */
contract BondingCurveToken is Ownable2Step, ERC20 {
    using SafeERC20 for IERC20;

    uint256 public constant PRICE_INCREASEMENT = 1;
    // When selling token, will charge a fee of received reserves. Here is 0.05%
    uint256 public constant FEE = 5;
    uint256 public constant FEE_PRECISION = 10000;

    // Reserve token address
    address public reserveToken;
    // Total reserves
    uint256 public reserves;
    // Reserve token decimals
    uint256 public reserveDecimals;
    // Current token price
    uint256 public tokenPrice;

    event Buy(address indexed buyer, address indexed recipient, uint256 amount, uint256 cost);
    event Sell(address indexed seller, address indexed recipient, uint256 amount, uint256 received);
    event WithdrawReserve(address recipient, uint256 amount);

    error ReverseTokenIsZeroAddress();
    error BuyingAmountIsZero();
    error BuyingSlippageExceeded();
    error RecipientIsZeroAddress();
    error SellingAmountIsZero();
    error InsufficientReserveAmount();
    error SellingSlippageExceeded();
    error InsufficientTokenAmount();

    /*//////////////////////////////////////////////////////////////
                           Constructor
    //////////////////////////////////////////////////////////////*/
    constructor(string memory name, string memory symbol, address _reverseToken)
        ERC20(name, symbol)
        Ownable(msg.sender)
    {
        reserveDecimals = uint256(IERC20Metadata(_reverseToken).decimals());
        reserveToken = _reverseToken;
    }

    /*//////////////////////////////////////////////////////////////
                           Owner function
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Only can be called by the owner
     * @dev Withdraw the reserve token from the contract
     * @param recipient The address to receive the reserve token
     */
    function _withdrawReserves(address recipient) external onlyOwner {
        uint256 reserveToWithdraw = reserves;
        reserves = 0;
        IERC20(reserveToken).safeTransfer(recipient, reserveToWithdraw);

        emit WithdrawReserve(recipient, reserveToWithdraw);
    }

    /*//////////////////////////////////////////////////////////////
                           Public functions
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Use `maxCostAmount` to avoid slippage
     * @dev Buy token with reserve token
     * @param recipient The address to receive the token
     * @param amount The amount of token to buy
     * @param maxCostAmount The maximum cost amount of reserve token
     * @return totalCost The total cost of reserve token
     */
    function buy(address recipient, uint256 amount, uint256 maxCostAmount) external returns (uint256) {
        if (amount == 0) revert BuyingAmountIsZero();

        (uint256 totalCost, uint256 nextPrice) = _calculateBuyCost(amount);
        if (totalCost > maxCostAmount) revert BuyingSlippageExceeded();
        if (totalCost > IERC20(reserveToken).balanceOf(msg.sender)) {
            revert InsufficientReserveAmount();
        }

        tokenPrice = nextPrice;
        _mint(recipient, amount);

        IERC20(reserveToken).safeTransferFrom(msg.sender, address(this), totalCost);

        emit Buy(msg.sender, recipient, amount, totalCost);

        return totalCost;
    }

    /**
     * @notice Use `minReceivedAmount` to avoid slippage
     * @dev Sell token to get reserve token
     * @param recipient The address to receive the reserve token
     * @param amount The amount of token to sell
     * @param minReceivedAmount The minimum amount of reserve token to receive
     * @return totalReceived The total received reserve token
     */
    function sell(address recipient, uint256 amount, uint256 minReceivedAmount) external returns (uint256) {
        if (recipient == address(0)) revert RecipientIsZeroAddress();
        if (amount == 0) revert SellingAmountIsZero();

        (uint256 totalReceived, uint256 nextPrice) = _calculateSellReceived(amount);
        

        if (amount > balanceOf(msg.sender)) {
            revert InsufficientTokenAmount();
        }

        tokenPrice = nextPrice;
        _burn(msg.sender, amount);

        uint256 fee = totalReceived * FEE / FEE_PRECISION;
        reserves = reserves + fee;
        totalReceived = totalReceived - fee;
        if (totalReceived < minReceivedAmount) {
            revert SellingSlippageExceeded();
        }
        IERC20(reserveToken).safeTransfer(recipient, totalReceived);

        emit Sell(msg.sender, recipient, amount, totalReceived);

        return totalReceived;
    }

    /*//////////////////////////////////////////////////////////////
                        Public View functions
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Keep the same decimals with reserve token
     * @dev Get the decimals of the token
     */
    function decimals() public view override returns (uint8) {
        return uint8(reserveDecimals);
    }

    /**
     * @dev Calculate the total cost of buying token
     * @param amount The amount of token to buy
     * @return totalCost The total cost of reserve token
     * @return nextPrice The next price of token
     */
    function calculateBuyCost(uint256 amount) public view returns (uint256, uint256) {
        return _calculateBuyCost(amount);
    }

    /**
     * @dev Calculate the total received of selling token
     * @param amount The amount of token to sell
     * @return totalReceived The total received reserve token
     * @return nextPrice The next price of token
     */
    function calculateSellReceived(uint256 amount) public view returns (uint256, uint256) {
        return _calculateSellReceived(amount);
    }

    /*//////////////////////////////////////////////////////////////
                            Internal functions
    //////////////////////////////////////////////////////////////*/
    /*
     * @dev Calculate the total cost of buying token
     */
    function _calculateBuyCost(uint256 amount) internal view returns (uint256 totalCost, uint256 nextPrice) {
        nextPrice = tokenPrice + amount * PRICE_INCREASEMENT;
        totalCost = (tokenPrice + 1 + nextPrice) * amount >> 1;
    }

    /*
     * @dev Calculate the total received of selling token
     */
    function _calculateSellReceived(uint256 amount) internal view returns (uint256 totalReceived, uint256 nextPrice) {
        nextPrice = tokenPrice - (amount - 1) * PRICE_INCREASEMENT;
        totalReceived = (tokenPrice + nextPrice) * amount >> 1;
    }
}
