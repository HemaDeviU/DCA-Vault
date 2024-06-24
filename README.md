# Money Plant 

### Deployed on Avalanche Testnet
### Contract Addresses 

**DCAStrategy:**
```0x01329bde1fe59e0de3e59a3591992b7e4077f8da ```
**DCAOut:**
```0x3217391376376d02fe867ea557e400410624d624 ```

## Tldr;
I love DCAing, with hopes of being financially stable. But most of the time, I forget to take profits or just wait a little more(really), to make some extra. As much as we take time to SIP every month or week, we often miss taking profits even if the price touches the moon. I wanted to solve this, for me and every other investor.

**What it does**

Let's a user Dollar Cost Average with a strategy. A user can keep sending tokens(like piggy bank) to the contract whenever they save which is supplied to the Aave pool to generate minimal profits until the Keepers trigger the date/time of DCA frequency(to make best use, without keeping the funds idle). Then, the amount is withdrawn from aave and swapped according to the DCA(usually for a blue-chip) pre-set strategy. A user also has an option to DCA-out with a set-strategy that withdraws their holdings to their wallet.The user can also withdraw their amount according to their will as well,anytime.

**How we built it**

Using Solidity, Foundry, Remix,Chainlink, Aave and Uniswap


## Overview
Money Plant is a decentralized investment strategy platform that automates the process of Dollar-Cost Averaging (DCA) and profit realization for users. By leveraging Aave's lending pool, Uniswap's swapping capabilities, and Chainlink's automation and price feeds, Money Plant ensures that users can effortlessly manage their investments, benefiting from both automated DCA strategies and additional yields from Aave's lending pool.

## Key Features
1. **Automated Dollar-Cost Averaging (DCA):** Users can deposit funds into the vault and set up DCA strategies to invest their funds at regular intervals.
2. **Automated Profit Realization (DCA Out):** Users can set target prices to automatically realize profits when their investments reach the desired price levels.
3. **Aave Pool Integration:** Funds deposited by users are supplied to Aave's lending pool to earn extra returns.
4. **Uniswap Integration:** Utilizes Uniswap for efficient and decentralized token swaps as part of the DCA process.
**Chainlink Automation:** Ensures reliable and timely execution of DCA and profit  realization strategies.

## Key Features
1. **Automated Dollar-Cost Averaging (DCA):** Users can deposit funds into the vault and set up DCA strategies to invest their funds at regular intervals.
2. **Automated Profit Realization (DCA Out):** Users can set target prices to automatically realize profits when their investments reach the desired price levels.
3. **Aave Pool Integration:** Funds deposited by users are supplied to Aave's lending pool to earn extra returns.
4. **Uniswap Integration:** Utilizes Uniswap for efficient and decentralized token swaps as part of the DCA process.
**Chainlink Automation:** Ensures reliable and timely execution of DCA and profit  realization strategies.

## Future Plans

We aim to enhance Money Plant by expanding its capabilities to support cross-chain investments. Our future plans include:


**Cross-Chain Investments:** Enable users to add funds on one blockchain and invest across different chain tokens by leveraging the power of Chainlink's Cross-Chain Interoperability Protocol (CCIP).

**Enhanced Liquidity Pools:** Integrate additional liquidity pools across multiple chains to maximize user returns and diversify investment opportunities.

**Advanced Automation:** Implement more sophisticated automation strategies for DCA and profit realization, making the platform even more user-friendly and efficient.

**User-Friendly Interface:** Develop a more intuitive and interactive user interface to simplify cross-chain investment management.

**Security Enhancements:** Continuously improve the security measures to protect user funds and ensure safe cross-chain transactions.


These enhancements will provide users with greater flexibility, broader investment opportunities, and a seamless experience across multiple blockchain ecosystems.

Money Plant aims to simplify and automate the investment process for users, combining the benefits of regular DCA with the ability to automatically realize profits based on market conditions. With the integration of Aave, Uniswap, and Chainlink, Money Plant provides a robust and efficient platform for decentralized investment strategies.
