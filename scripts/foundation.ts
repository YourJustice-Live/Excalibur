// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

//Track Addresses (Fill in present addresses to prevent new deplopyment)
// import contractAddr from "./_contractAddr";

//Deployed to 0x4784450ED6075EFA886437F5fC288eE9FEd9fba9


/**
 * Deploy Independent Public Agents
 */
async function main() {

  //--- Assoc Repo
//   if(!contractAddr.assocRepo){
    //Deploy Config
    let contractInstance = await ethers.getContractFactory("AssocRepo").then(res => res.deploy());
    await contractInstance.deployed();
    //Set Address
    // contractAddr.assocRepo = contractInstance.address;
    //Log
    console.log("Deployed AssocRepo Contract to " + contractInstance.address);
//   }

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
