// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

import { ethers } from "hardhat";
const {  upgrades } = require("hardhat");

// import publicAddr from "./_publicAddrs";
import contractAddr from "./_contractAddr";

let oldHubAddr = "0x25b1c6923a42F00028F878ff4D01B2030Cb69D75";

/**
 * Deploy Independent Public Agents
 */
async function main() {


    /* Non-Upgradable Hub */
    //Old Hub
    let oldHubContract = await ethers.getContractFactory("Hub").then(res => res.attach(oldHubAddr));
    //Move Asset Contracts to new Hub
    oldHubContract.hubChange(contractAddr.hub);     //TX FAILS


    /* Upgradable Hub
    let oldHubContract = await ethers.getContractFactory("HubUpgradable").then(res => res.attach(oldHubAddr));
    let newHubContract = await ethers.getContractFactory("HubUpgradable").then(res => res.attach(contractAddr.hub));

    
    //Register Beacon
    // await upgrades.forceImport(oldHubContract.address, OldImplementation);
    //Validate Upgrade
    await upgrades.prepareUpgrade(oldHubContract.address, newHubContract);

    //Upgrade
    // await upgrades.upgradeProxy(oldHubContract, newHubContract);

    //Attach
    // const newFactoryContract = await newHubContract.attach(oldHubContract.address);

    //Log
    console.log("Hub Updated Contract Updated");
    */
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
