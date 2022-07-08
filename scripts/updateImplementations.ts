// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

import { ethers } from "hardhat";
const { upgrades } = require("hardhat");
const hre = require("hardhat");
const chain = hre.hardhatArguments.network;

import contractAddrs from "./_contractAddr";
const contractAddr = contractAddrs[chain];

/**
 * Migrate Contracts Between Hubs
 */
async function main() {
    //Hub
    let hubContract = await ethers.getContractFactory("HubUpgradable").then(res => res.attach(contractAddr.hub));
    //Update Implementations
    // await hubContract.upgradeIncidentImplementation(contractAddr.incident);
    // await hubContract.upgradeGameImplementation(contractAddr.game);

    //Set to HUB
    await hubContract.setAssoc("avatar", contractAddr.avatar);
    await hubContract.setAssoc("history", contractAddr.history);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
