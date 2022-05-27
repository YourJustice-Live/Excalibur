// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

// import { ethers } from "hardhat";
const { ethers, upgrades } = require("hardhat");
import contractAddr from "./_contractAddr";
const proxyAddress = contractAddr.hub;


async function main() {
    //Validate
    if(!proxyAddress) throw "Missing Factory Address";

    //Accounts
    // const [deployer, admin] = await ethers.getSigners();

    //Log
    // console.log("Deployer account:", deployer.address);

    console.log("Update Factory Proxy:");

    //Fetch New Implementation Contract
    let NewImplementation = await ethers.getContractFactory("AvatarUpgradable");
    
    //Validate Upgrade
    await upgrades.prepareUpgrade(proxyAddress, NewImplementation);

    //Upgrade    
    // await upgrades.upgradeProxy(factoryContract, NewImplementation);

    //Attach
    // const newFactoryContract = await NewImplementation.attach(factoryContract.address);
    //Set Config

    //Log
    console.log("AvatarUpgradable Contract Updated");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
