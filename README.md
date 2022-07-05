# The Excalibur Protocol 

![The Excalibur Protocol](doc/images/cover.png)

Using the magic of cryptographic technology to bring balance to the world and promote decentralized justice.

## Overview

The Excalibur Protocol is an on-chain justice system, carefully designed to imitate the same innate human social structures that the traditional justice system is based on. 

## Technical info

- [Docs (Notion)](https://www.notion.so/yourjustice/Smart-Contracts-b9b89738497647b4beb3c353284f49b1)
- [Changelog](https://github.com/YourJustice-Live/Excalibur/releases)

## Getting Started

### Environment

Clone .env.example to .env and fill in your environment parameters

### Commands

- Install environemnt: `npm install`
- Run tests: `npx hardhat test`
- Check contract size: `npx hardhat size-contracts`
- Deploy protocol (Rinkeby): `npx hardhat run scripts/deploy.ts --network rinkeby`
- Deploy foundation (Mumbai): `npx hardhat run scripts/foundation.ts --network mumbai`
- Deploy protocol (Mumbai): `npx hardhat run scripts/deploy.ts --network mumbai`
- Compile contracts: `npx hardhat compile`
- Cleanup: `npx hardhat clean`

### Etherscan verification

Enter your Etherscan API key into the .env file and run the following command 
(replace `DEPLOYED_CONTRACT_ADDRESS` with the contract's address and "Hello, Hardhat!" with the parameters you sent the contract upon deployment:

```shell
npx hardhat verify --network ropsten DEPLOYED_CONTRACT_ADDRESS "Hello, Hardhat!"
```
