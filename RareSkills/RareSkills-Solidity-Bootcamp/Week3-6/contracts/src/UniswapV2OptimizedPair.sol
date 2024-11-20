// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {IERC3156FlashLender} from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import {IUniswapV2Factory} from "./interfaces/IUniswapV2Factory.sol";
import {ReentrancyGuard} from "solady/utils/ReentrancyGuard.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {UniswapV2OptimizedERC20} from "./UniswapV2OptimizedERC20.sol";
import {UQ112x112} from "./libraries/UQ112x112.sol";

contract UniswapV2OptimizedPair is IERC3156FlashLender, ReentrancyGuard, UniswapV2OptimizedERC20 {
    using UQ112x112 for uint224;
    using FixedPointMathLib for uint256;
    using SafeTransferLib for address;

    uint256 public constant MINIMUM_LIQUIDITY = 10 ** 3;

    address public immutable factory;
    address public token0;
    address public token1;

    uint112 private reserve0; // uses single storage slot, accessible via getReserves
    uint112 private reserve1; // uses single storage slot, accessible via getReserves
    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    event Mint(address indexed spender, address indexed recipient, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender, address indexed tokenIn, uint256 amountIn, uint256 amountOut, address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    error Expired();
    error NotFactory();
    error Overflow();
    error InputLiquidityIsZero();
    error InsufficientLiquidity();
    error InsufficientAmount1();
    error InsufficientAmount0();
    error InsufficientLiquidityMinted();
    error InsufficientLiquidityBurned();
    error InsufficientOutputAmount();
    error InvalidTo();
    error InvalidInput();
    error InvalidToken();
    error FlashLenderCallbackFailed();

    modifier ensure(uint256 deadline) {
        if (deadline < block.timestamp) revert Expired();
        _;
    }

    constructor() {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        if (msg.sender != factory) revert NotFactory();
        token0 = _token0;
        token1 = _token1;
    }

    struct MintVars {
        bool _feeOn;
        uint112 _reserve0;
        uint112 _reserve1;
        address _token0;
        address _token1;
        uint256 _amount0Optimal;
        uint256 _amount1Optimal;
        uint256 _balance0;
        uint256 _balance1;
        uint256 _totalSupply;
    }

    function mint(
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 amount0Min,
        uint256 amount1Min,
        address recipient,
        uint256 deadline
    ) external nonReentrant ensure(deadline) returns (uint256 amount0, uint256 amount1, uint256 liquidity) {
        MintVars memory vars;
        if (amount0Desired == 0 || amount1Desired == 0) revert InputLiquidityIsZero();

        (vars._reserve0, vars._reserve1,) = getReserves(); // gas savings
        vars._token0 = token0; // gas savings
        vars._token1 = token1; // gas savings

        if (vars._reserve0 == 0 && vars._reserve1 == 0) {
            (amount0, amount1) = (amount0Desired, amount1Desired);
        } else {
            if (vars._reserve0 == 0) revert InsufficientLiquidity();
            vars._amount1Optimal = amount0Desired.fullMulDiv(vars._reserve1, vars._reserve0);
            if (vars._amount1Optimal <= amount1Desired) {
                if (vars._amount1Optimal < amount1Min) revert InsufficientAmount1();
                (amount0, amount1) = (amount0Desired, vars._amount1Optimal);
            } else {
                if (vars._reserve1 == 0) revert InsufficientLiquidity();
                vars._amount0Optimal = amount1Desired.fullMulDiv(vars._reserve0, vars._reserve1);
                assert(vars._amount0Optimal <= amount0Desired);
                if (vars._amount0Optimal < amount0Min) revert InsufficientAmount0();
                (amount0, amount1) = (vars._amount0Optimal, amount1Desired);
            }
        }

        vars._token0.safeTransferFrom(msg.sender, address(this), amount0);
        vars._token1.safeTransferFrom(msg.sender, address(this), amount1);

        vars._balance0 = IERC20(vars._token0).balanceOf(address(this));
        vars._balance1 = IERC20(vars._token1).balanceOf(address(this));

        vars._feeOn = _mintFee(vars._reserve0, vars._reserve1);
        vars._totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        if (vars._totalSupply == 0) {
            liquidity = (amount0 * amount1).sqrt() - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = amount0.fullMulDiv(vars._totalSupply, vars._reserve0).min(
                amount1.fullMulDiv(vars._totalSupply, vars._reserve1)
            );
        }
        if (liquidity == 0) revert InsufficientLiquidityMinted();
        _mint(recipient, liquidity);

        _update(vars._balance0, vars._balance1, vars._reserve0, vars._reserve1);
        if (vars._feeOn) kLast = uint256(vars._reserve0) * vars._reserve1; // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, recipient, amount0, amount1);
    }

    struct BurnVars {
        bool _feeOn;
        uint112 _reserve0;
        uint112 _reserve1;
        address _token0;
        address _token1;
        uint256 _balance0;
        uint256 _balance1;
        uint256 _totalSupply;
    }

    function burn(uint256 liquidity, uint256 amount0Min, uint256 amount1Min, address recipient, uint256 deadline)
        external
        nonReentrant
        ensure(deadline)
        returns (uint256 amount0, uint256 amount1)
    {
        BurnVars memory vars;
        (vars._reserve0, vars._reserve1,) = getReserves(); // gas savings
        vars._token0 = token0; // gas savings
        vars._token1 = token1; // gas savings
        vars._balance0 = IERC20(vars._token0).balanceOf(address(this));
        vars._balance1 = IERC20(vars._token1).balanceOf(address(this));

        vars._feeOn = _mintFee(vars._reserve0, vars._reserve1);
        vars._totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.fullMulDiv(vars._balance0, vars._totalSupply); // using balances ensures pro-rata distribution
        amount1 = liquidity.fullMulDiv(vars._balance1, vars._totalSupply); // using balances ensures pro-rata distribution
        if (amount0 == 0 || amount1 == 0) revert InsufficientLiquidityBurned();
        if (amount0 < amount0Min) revert InsufficientAmount0();
        if (amount1 < amount1Min) revert InsufficientAmount1();

        _burn(msg.sender, liquidity);
        vars._token0.safeTransfer(recipient, amount0);
        vars._token1.safeTransfer(recipient, amount1);
        vars._balance0 = IERC20(vars._token0).balanceOf(address(this));
        vars._balance1 = IERC20(vars._token1).balanceOf(address(this));

        _update(vars._balance0, vars._balance1, vars._reserve0, vars._reserve1);
        if (vars._feeOn) kLast = uint256(reserve0) * reserve1; // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, recipient);
    }

    struct SwapVars {
        bool _inputIsToken0;
        uint112 _reserve0;
        uint112 _reserve1;
        address _token0;
        address _token1;
        uint256 _balance0;
        uint256 _balance1;
    }

    function swap(address tokenIn, uint256 amountIn, uint256 amountOutMin, address to, uint256 deadline)
        external
        nonReentrant
        ensure(deadline)
        returns (uint256 amountOut)
    {
        SwapVars memory vars;
        (vars._reserve0, vars._reserve1,) = getReserves(); // gas savings
        vars._token0 = token0;
        vars._token1 = token1;

        if (tokenIn == vars._token0) {
            amountOut = getAmountOut(amountIn, vars._reserve0, vars._reserve1);
            if (amountOut > vars._reserve1) revert InsufficientLiquidity();
            vars._inputIsToken0 = true;
        } else if (tokenIn == vars._token1) {
            amountOut = getAmountOut(amountIn, vars._reserve1, vars._reserve0);
            if (amountOut > vars._reserve0) revert InsufficientLiquidity();
        } else {
            revert InvalidToken();
        }

        if (amountOut < amountOutMin) revert InsufficientOutputAmount();
        if (to == vars._token0 || to == vars._token1) revert InvalidTo();

        tokenIn.safeTransferFrom(msg.sender, address(this), amountIn);
        if (vars._inputIsToken0) {
            vars._token1.safeTransfer(to, amountOut);
        } else {
            vars._token0.safeTransfer(to, amountOut);
        }

        vars._balance0 = IERC20(vars._token0).balanceOf(address(this));
        vars._balance1 = IERC20(vars._token1).balanceOf(address(this));

        _update(vars._balance0, vars._balance1, vars._reserve0, vars._reserve1);
        emit Swap(msg.sender, tokenIn, amountIn, amountOut, to);
    }

    function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes calldata data)
        external
        nonReentrant
        returns (bool)
    {
        if (amount == 0) revert InvalidInput();
        if (amount > maxFlashLoan(token)) revert InsufficientLiquidity();

        // Get the current reserves
        (uint112 _reserve0, uint112 _reserve1,) = getReserves();
        // Transfer tokens to the receiver
        token.safeTransfer(address(receiver), amount);
        // Charge fee on the borrowed amount
        uint256 fee = (amount * 3) / 1000;
        // Call the receiver's callback function
        if (receiver.onFlashLoan(msg.sender, token, amount, fee, data) != keccak256("ERC3156FlashBorrower.onFlashLoan"))
        {
            revert FlashLenderCallbackFailed();
        }
        // Transfer the borrowed tokens with fee back to the contract
        token.safeTransferFrom(address(receiver), address(this), amount + fee);
        // Update state
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        _update(balance0, balance1, _reserve0, _reserve1);
        return true;
    }

    // force balances to match reserves
    function skim(address to) external nonReentrant {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _token0.safeTransfer(to, IERC20(_token0).balanceOf(address(this)) - reserve0);
        _token1.safeTransfer(to, IERC20(_token1).balanceOf(address(this)) - reserve1);
    }

    // force reserves to match balances
    function sync() external nonReentrant {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        public
        pure
        returns (uint256 amountOut)
    {
        if (amountIn == 0) return 0;
        if (reserveIn == 0 || reserveOut == 0) revert InsufficientLiquidity();

        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IUniswapV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = (uint256(_reserve0) * _reserve1).sqrt();
                uint256 rootKLast = _kLast.sqrt();
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply() * (rootK - rootKLast);
                    uint256 denominator = rootK * 5 + rootKLast;
                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function maxFlashLoan(address token) public view override returns (uint256 amount) {
        if (token != token0 && token != token1) revert InvalidToken();
        amount = token == token0 ? reserve0 : reserve1;
    }

    function flashFee(address token, uint256 amount) public view override returns (uint256 fee) {
        if (token != token0 && token != token1) revert InvalidToken();
        fee = amount.fullMulDiv(3, 1000);
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(uint256 balance0, uint256 balance1, uint112 _reserve0, uint112 _reserve1) private {
        if (balance0 > type(uint112).max || balance1 > type(uint112).max) revert Overflow();
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB) {
        // require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        if (amountA == 0) return 0;
        if (reserveA == 0 || reserveB == 0) revert InsufficientLiquidity();

        amountB = amountA.fullMulDiv(reserveB, reserveA);
    }
}
