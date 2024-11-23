[+] Report:
Mutation testing report:
Number of mutations:    52
Killed:                 37 / 52

Mutations:

[+] Survivors
Mutation:
    File: /Users/Week2/contracts/src/ecosystem1/RewardToken.sol
    Line nr: 30
    Result: Lived
    Original line:
             function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {

    Mutated line:
             function mint(address to, uint256 amount) external  {

Mutation:
    File: /Users/Week2/contracts/src/ecosystem2/EnumerableNFT.sol
    Line nr: 29
    Result: Lived
    Original line:
                 if (currentTokenId > MAX_SUPPLY) {

    Mutated line:
                 if (currentTokenId >= MAX_SUPPLY) {

Mutation:
    File: /Users/Week2/contracts/src/ecosystem2/EnumerableNFT.sol
    Line nr: 29
    Result: Lived
    Original line:
                 if (currentTokenId > MAX_SUPPLY) {

    Mutated line:
                 if (currentTokenId <= MAX_SUPPLY) {

Mutation:
    File: /Users/Week2/contracts/src/ecosystem2/EnumerableNFT.sol
    Line nr: 34
    Result: Lived
    Original line:
                 _safeMint(to, currentTokenId);

    Mutated line:


Mutation:
    File: /Users/Week2/contracts/src/ecosystem1/NFTStaking.sol
    Line nr: 104
    Result: Lived
    Original line:
                 if (rewardsAmount > 0) {

    Mutated line:
                 if (rewardsAmount >= 0) {

Mutation:
    File: /Users/Week2/contracts/src/ecosystem1/NFTStaking.sol
    Line nr: 130
    Result: Lived
    Original line:
                 if (rewardsAmount > 0) {

    Mutated line:
                 if (rewardsAmount >= 0) {

Mutation:
    File: /Users/Week2/contracts/src/ecosystem1/NFTStaking.sol
    Line nr: 102
    Result: Lived
    Original line:
                 uint256 dayPassed = (block.timestamp - nftInfo.lastClaimedTime) / 1 days;

    Mutated line:
                 uint256 dayPassed = (block.timestamp + nftInfo.lastClaimedTime) / 1 days;

Mutation:
    File: /Users/Week2/contracts/src/ecosystem1/NFTStaking.sol
    Line nr: 128
    Result: Lived
    Original line:
                 uint256 dayPassed = (block.timestamp - nftInfo.lastClaimedTime) / 1 days;

    Mutated line:
                 uint256 dayPassed = (block.timestamp + nftInfo.lastClaimedTime) / 1 days;

Mutation:
    File: /Users/Week2/contracts/src/ecosystem1/NFTStaking.sol
    Line nr: 135
    Result: Lived
    Original line:
                     nftInfo.lastClaimedTime = nftInfo.lastClaimedTime + dayPassed * 1 days;

    Mutated line:
                     nftInfo.lastClaimedTime = nftInfo.lastClaimedTime + dayPassed / 1 days;

Mutation:
    File: /Users/Week2/contracts/src/ecosystem1/MyNFT.sol
    Line nr: 53
    Result: Lived
    Original line:
                 _setDefaultRoyalty(_royaltyFeeRecipient, ROYALTY_FEE);

    Mutated line:


[*] Done!
