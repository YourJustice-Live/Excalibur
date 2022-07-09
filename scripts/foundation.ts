// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import { verify } from "../utils/deployment";
const { upgrades } = require("hardhat");
const hre = require("hardhat");
const chain = hre.hardhatArguments.network;

//Track Addresses (Fill in present addresses to prevent new deplopyment)
import publicAddrs from "./_publicAddrs";
const publicAddr = publicAddrs[chain];

console.log()

/**
 * Deploy Independent Public Agents
 */
async function main() {

  /* DEPRECATED
  //--- Assoc Repo
  if(!publicAddr.assocRepo){
      //Deploy Config
      let contractInstance = await ethers.getContractFactory("AssocRepo").then(res => res.deploy());
      await contractInstance.deployed();
      //Set Address
      publicAddr.assocRepo = contractInstance.address;
      //Log
      console.log("Deployed AssocRepo Contract to " + contractInstance.address);
  }
  */

  //--- Open Repo
  if(!publicAddr.openRepo){
    //Deploy OpenRepo Upgradable (UUPS)
    let contractInstance = await ethers.getContractFactory("OpenRepoUpgradable").then(Contract => 
      upgrades.deployProxy(Contract, [],{
        kind: "uups",
        timeout: 120000
      })
    );
    //Set Address
    publicAddr.openRepo = contractInstance.address;
    //Log
    console.log("Deployed OpenRepo Contract to Chain:"+chain+" Address:" + contractInstance.address);
    console.log("Run: npx hardhat verify --network "+chain+" " + contractInstance.address);
    
    //Verify on Etherscan
    await verify(contractInstance.address, []);
  }

  //--- Rule Repo
  if(!publicAddr.ruleRepo){
    //Deploy RuleRepo
    let contractInstance = await ethers.getContractFactory("RuleRepo").then(res => res.deploy());
    //Set Address
    publicAddr.ruleRepo = contractInstance.address;
    //Log
    console.log("Deployed RuleRepo Contract to Chain:"+chain+" Address:" + contractInstance.address);
    // console.log("Run: npx hardhat verify --network "+chain+" " + contractInstance.address);

    //Verify on Etherscan
    await verify(contractInstance.address, []);
  }

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
