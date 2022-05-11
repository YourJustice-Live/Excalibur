<img src="https://i.ibb.co/MMVvLZp/Excalibur-transparent-2.png" align="right" style="width:42%"/>

# The Excalibur Protocol 

<img src="https://media.discordapp.net/attachments/951793998362705950/970763106286460968/contracts.png" alt="Version 0.2"/>

Using the magic of cryptographic technology to bring balance to the world and promote decentralized justice.

## Overview

The Excalibur Protocol is an on-chain justice system, carefully designed to imitate the same innate human social structures that the traditional justice system is based on. 




## Technical info

- [Docs (Notion)](https://www.notion.so/yourjustice/Smart-Contracts-b9b89738497647b4beb3c353284f49b1)
- [Architecture (Miro)](https://miro.com/app/board/uXjVOGibO84=/)
- [Changelog](https://github.com/YourJustice-Live/Excalibur/releases)

## Getting Started

### .env file

Create an .env file and fill in your infura API key and the private key of the account which will send the deployment transaction.


```shell

INFURA_KEY = 
PRIVATE_KEY = 
ETHERSCAN_API_KEY = 

```


### Some Basic Commands

- Install environemnt: `npm install`
- Run tests: `npx hardhat test`
- Check contract size: `npx hardhat size-contracts`
- Deploy (to rinkeby): `npx hardhat run scripts/deploy.ts --network rinkeby`
- Compile contracts: `npx hardhat compile`
- Cleanup: `npx hardhat clean`

### Etherscan verification

Enter your Etherscan API key into the .env file and run the following command 
(replace `DEPLOYED_CONTRACT_ADDRESS` with the contract's address ans "Hello, Hardhat!" with the parameters you sent the contract upon deployment:

```shell
npx hardhat verify --network ropsten DEPLOYED_CONTRACT_ADDRESS "Hello, Hardhat!"
```
