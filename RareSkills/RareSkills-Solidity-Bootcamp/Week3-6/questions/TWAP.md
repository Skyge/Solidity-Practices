- **1.1Why does the `price0CumulativeLast` and `price1CumulativeLast` never decrement?**
  - The cumulative price values are calculated based on the time-weighted average of the asset prices. They are updated every time there is a swap or liquidity provision in the pool. The type of these variables are `uint256`, and when they reach the maximum value (2^256 - 1), they wrap around to zero, but when computing price averages, will use the difference between two cumulative price observations, not the absolute values.

- **1.2How do you write a contract that uses the oracle?**
  - To compute the average price given two cumulative price observations, take the difference between the cumulative price at the beginning and end of the period, and divide by the elapsed time between them in seconds.
  - [ExampleOracleSimple.sol](https://github.com/Uniswap/v2-periphery/blob/master/contracts/examples/ExampleOracleSimple.sol)
  - [ExampleSlidingWindowOracle.sol](https://github.com/Uniswap/v2-periphery/blob/master/contracts/examples/ExampleSlidingWindowOracle.sol)

- **1.3 Why are price0CumulativeLast and price1CumulativeLast stored separately? Why not just calculate `price1CumulativeLast = 1/price0CumulativeLast`?**
  - `price0CumulativeLast` represents the price of token0 in terms of token1.
`price1CumulativeLast` represents the price of token1 in terms of token0. Simply inverting one price to get the other wouldn't work correctly when accumulating prices over time. For example, (1/(2+3)) ≠ (1/2) + (1/3)

## References

- [Uniswap TWAP](https://www.rareskills.io/post/twap-uniswap-v2)
- [Uniswap V2 Oracle](https://docs.uniswap.org/contracts/v2/guides/smart-contract-integration/building-an-oracle)

