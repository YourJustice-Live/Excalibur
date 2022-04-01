// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

//Track Addresses (Fill in present addresses to prevent new deplopyment)
const contractAddr = {
  config:"0xe42a960537e1fB2F39361b6cffFa6CeD6162752b",
  hub:"0xdd2e3c7d34ea7f5876bf7a05775106968b80ba83",
  avatar:"0xAb4B21d7651b1484986E1D2790b125be8b6c460B",
  history:"0x550AB560c34F122665beC8B40897B800913D0F4d", //V2
  jurisdiction:"",
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
    await configContract.deployed();
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
    await hubContract.deployed();
    //Set Address
    contractAddr.hub = hubContract.address;
    //Log
    console.log("Deployed Hub Contract to " + contractAddr.hub);
  }

  //--- Avatar
  if(!contractAddr.avatar){
    //Deploy Avatar
    const AvatarContract = await ethers.getContractFactory("AvatarNFT");
    let avatarContract = await AvatarContract.deploy(contractAddr.hub);
    await avatarContract.deployed();
    //Set Address
    contractAddr.avatar = avatarContract.address;
    //Log
    console.log("Deployed Avatar Contract to " + contractAddr.avatar);
  }

  //--- Action Repo
  if(!contractAddr.history){
    let actionContract = await ethers.getContractFactory("ActionRepo").then(res => res.deploy(contractAddr.hub));
    await actionContract.deployed();
    //Set Address
    contractAddr.history = actionContract.address;
    //Log
    console.log("Deployed ActionRepo Contract to " + contractAddr.history);
  }

  //--- Jurisdiction
  if(!contractAddr.jurisdiction){
    //Deploy Avatar
    const JurisdictionContract = await ethers.getContractFactory("Jurisdiction");
    let jurisdictionContract = await JurisdictionContract.deploy(contractAddr.hub, contractAddr.history);
    await jurisdictionContract.deployed();
    
    //Assign Admin
    jurisdictionContract.roleAssign("0x4306D7a79265D2cb85Db0c5a55ea5F4f6F73C4B1", "admin");

    //Set Address
    contractAddr.jurisdiction = jurisdictionContract.address;
    //Log
    console.log("Deployed Jurisdiction Contract to " + contractAddr.jurisdiction+ " Hub: "+ contractAddr.hub+ " History: "+ contractAddr.history);
  }

  /*
  try{
    // Verify your contracts with Etherscan
    console.log("Start code verification on etherscan");
    await run("verify:verify", {
        address: contractAddr.avatar,
        contract: "contracts/AvatarNFT.sol:AvatarNFT",
        contractArguments: [contractAddr.hub],
    });
    console.log("End code verification on etherscan");
  }
  catch(error){
      console.error("Faild Etherscan Verification", error);
  }*/

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

/*
function etherscanVerify(address, contract, contractArguments){
  try{
    // Verify your contracts with Etherscan
    console.log("Start code verification on etherscan");
    await run("verify:verify", {
        // address: "0x938Ce74dee47035C58a9aFeA1FC13B48BA8Dbe3d",
        // contract: "contracts/Config.sol:Config",
        // contractArguments: [],
        address,
        contract,
        contractArguments,
    });
    console.log("End code verification on etherscan");
  }
  catch(error){
      console.error("Faild Etherscan Verification", error);
  }
}
*/