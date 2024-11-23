Mutation testing report:
Number of mutations:    62
Killed:                 46 / 62

Mutations:

[+] Survivors
Mutation:
    File: /Users/Week1/contracts/src/BondingCurveToken.sol
    Line nr: 92
    Result: Lived
    Original line:
                 if (totalCost > maxCostAmount) revert BuyingSlippageExceeded();

    Mutated line:
                 if (totalCost >= maxCostAmount) revert BuyingSlippageExceeded();

Mutation:
    File: /Users/Week1/contracts/src/BondingCurveToken.sol
    Line nr: 93
    Result: Lived
    Original line:
                 if (totalCost > IERC20(reserveToken).balanceOf(msg.sender)) {

    Mutated line:
                 if (totalCost >= IERC20(reserveToken).balanceOf(msg.sender)) {

Mutation:
    File: /Users/Week1/contracts/src/BondingCurveToken.sol
    Line nr: 132
    Result: Lived
    Original line:
                 if (totalReceived < minReceivedAmount) {

    Mutated line:
                 if (totalReceived <= minReceivedAmount) {

Mutation:
    File: /Users/Week1/contracts/src/BondingCurveToken.sol
    Line nr: 180
    Result: Lived
    Original line:
                 nextPrice = tokenPrice + amount * PRICE_INCREASEMENT;

    Mutated line:
                 nextPrice = tokenPrice + amount / PRICE_INCREASEMENT;

Mutation:
    File: /Users/Week1/contracts/src/BondingCurveToken.sol
    Line nr: 181
    Result: Lived
    Original line:
                 totalCost = (tokenPrice + 1 + nextPrice) * amount >> 1;

    Mutated line:
                 totalCost = (tokenPrice + 1 + nextPrice) * amount << 1;

Mutation:
    File: /Users/Week1/contracts/src/BondingCurveToken.sol
    Line nr: 188
    Result: Lived
    Original line:
                 nextPrice = tokenPrice - (amount - 1) * PRICE_INCREASEMENT;

    Mutated line:
                 nextPrice = tokenPrice - (amount - 1) / PRICE_INCREASEMENT;

Mutation:
    File: /Users/Week1/contracts/src/BondingCurveToken.sol
    Line nr: 189
    Result: Lived
    Original line:
                 totalReceived = (tokenPrice + nextPrice) * amount >> 1;

    Mutated line:
                 totalReceived = (tokenPrice - nextPrice) * amount >> 1;

Mutation:
    File: /Users/Week1/contracts/src/BondingCurveToken.sol
    Line nr: 69
    Result: Lived
    Original line:
             function _withdrawReserves(address recipient) external onlyOwner {

    Mutated line:
             function _withdrawReserves(address recipient) external  {

Mutation:
    File: /Users/Week1/contracts/src/UntrustedEscrow.sol
    Line nr: 53
    Result: Lived
    Original line:
                 uint256 actualAmount = newBalance - currentBalance;

    Mutated line:
                 uint256 actualAmount = newBalance + currentBalance;

[*] Done!
