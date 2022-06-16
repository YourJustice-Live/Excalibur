// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

import { ethers } from "hardhat";
const {  upgrades } = require("hardhat");

// import publicAddr from "./_publicAddrs";
import contractAddr from "./_contractAddr";

let oldHubAddr = "0x288B2040e78dC90D73d8Ed0957ed706260DC8EfE";

/**
 * Migrate Contracts Between Hubs
 */
async function main() {
    //Old Hub
    let oldHubContract = await ethers.getContractFactory("HubUpgradable").then(res => res.attach(oldHubAddr));
    //Move Asset Contracts to new Hub
    oldHubContract.hubChange(contractAddr.hub);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
