// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

//Track Addresses (Fill in present addresses to prevent new deplopyment)
const contractAddr = {
  config:"",
  hub:"",
  avatar:"",
};

async function main() {
  /*
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Greeter = await ethers.getContractFactory("Greeter");
  const greeter = await Greeter.deploy("Hello, Hardhat!");

  await greeter.deployed();

  console.log("Greeter deployed to:", greeter.address);
  */

  //--- Config
  if(!contractAddr.config){
    //Deploy Config
    const ConfigContract = await ethers.getContractFactory("Config");
    let configContract = await ConfigContract.deploy();
    //Set Address
    contractAddr.config = configContract.address;
    //Log
    console.log("Deployed Config Contract to " + contractAddr.config);
  }

  //--- Hub
  if(!contractAddr.hub){
    //Deploy Hub
    const HubContract = await ethers.getContractFactory("Hub");
    let hubContract = await HubContract.deploy(contractAddr.config);
    //Set Address
    contractAddr.hub = hubContract.address;
    //Log
    console.log("Deployed Hub Contract to " + contractAddr.config);
  }

  //--- Avatar
  //Deploy Avatar
  const AvatarContract = await ethers.getContractFactory("AvatarNFT");
  let avatarContract = await AvatarContract.deploy(contractAddr.hub);
  //Set Address
  contractAddr.avatar = avatarContract.address;
  //Log
  console.log("Deployed Avatar Contract to " + contractAddr.avatar);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
