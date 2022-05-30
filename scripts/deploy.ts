// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
const {  upgrades } = require("hardhat");

//Track Addresses (Fill in present addresses to prevent new deplopyment)
import contractAddr from "./_contractAddr";
import publicAddr from "./_publicAddrs";


async function main() {

  let hubContract;

  //--- Config
  if(!contractAddr.config){
    //Deploy Config
    let configContract = await ethers.getContractFactory("Config").then(res => res.deploy());
    await configContract.deployed();
    //Set Address
    contractAddr.config = configContract.address;
    //Log
    console.log("Deployed Config Contract to " + contractAddr.config);
  }

  //--- Jurisdiction Implementation
  if(!contractAddr.jurisdiction){
    //Deploy Jurisdiction
    let contract = await ethers.getContractFactory("JurisdictionUpgradable").then(res => res.deploy());
    await contract.deployed();
    //Set Address
    contractAddr.jurisdiction = contract.address;
    //Log
    console.log("Deployed Jurisdiction Contract to " + contractAddr.jurisdiction);
    console.log("Run: npx hardhat verify --network rinkeby " + contractAddr.jurisdiction);
  }

  //--- Case Implementation
  if(!contractAddr.case){
    //Deploy Case
    let contract = await ethers.getContractFactory("CaseUpgradable").then(res => res.deploy());
    await contract.deployed();
    //Set Address
    contractAddr.case = contract.address;
    //Log
    console.log("Deployed Case Contract to " + contractAddr.case);
    console.log("Run: npx hardhat verify --network rinkeby " + contractAddr.case);
  }

  //--- Hub
  if(!contractAddr.hub){
    //Deploy Hub
    hubContract = await ethers.getContractFactory("Hub").then(res => res.deploy(
        contractAddr.config, 
        contractAddr.jurisdiction,
        contractAddr.case,
      ));
    await hubContract.deployed();

    //Set Avatars
    if(!!contractAddr.avatar) await hubContract.setAssoc("avatar", contractAddr.avatar);
    //Set to History
    if(!!contractAddr.history) await hubContract.setAssoc("history", contractAddr.history);

    //Set Address
    contractAddr.hub = hubContract.address;
    //Log
    console.log("Deployed Hub Contract to " + contractAddr.hub+ " Conf: "+ contractAddr.config+ " jurisdiction: "+contractAddr.jurisdiction+ " Case: "+ contractAddr.case);
    console.log("Run: npx hardhat verify --network rinkeby " + contractAddr.hub+ " "+ contractAddr.config+ " "+contractAddr.jurisdiction+ " "+contractAddr.case);
  }

  /*
  //--- Avatar
  if(!contractAddr.avatar){
    //Deploy Avatar
    let avatarContract = await ethers.getContractFactory("AvatarNFT").then(res => res.deploy(contractAddr.hub));
    await avatarContract.deployed();
    //Set Address
    contractAddr.avatar = avatarContract.address;
    //Log
    console.log("Deployed Avatar Contract to " + contractAddr.avatar);
    console.log("Run: npx hardhat verify --network rinkeby "+contractAddr.avatar+" "+contractAddr.hub);
    if(!!hubContract){  //If Deployed Together
      try{
        //Set to HUB
        hubContract.setAssoc("avatar", contractAddr.avatar);
      }
      catch(error){
        console.error("Failed to Set Avatar Contract to Hub", error);
      }
    }
  }
  */


  //--- Avatar Upgradable
  if(!contractAddr.avatar){
    //Deploy Avatar Upgradable
    const SoulUpgradable = await ethers.getContractFactory("SoulUpgradable");
    // deploying new proxy
    const proxyAvatar = await upgrades.deployProxy(SoulUpgradable,
        [contractAddr.hub],{
        // https://docs.openzeppelin.com/upgrades-plugins/1.x/api-hardhat-upgrades#common-options
        kind: "uups",
        timeout: 120000
    });
    await proxyAvatar.deployed();
    contractAddr.avatar = proxyAvatar.address;
    
    //Log
    console.log("Deployed Avatar Contract to " + contractAddr.avatar);
    console.log("Run: npx hardhat verify --network rinkeby "+contractAddr.avatar+" "+contractAddr.hub);
    if(!!hubContract){  //If Deployed Together
      try{
        //Set to HUB
        hubContract.setAssoc("avatar", contractAddr.avatar);
      }
      catch(error){
        console.error("Failed to Set Avatar Contract to Hub", error);
      }
    }
  }



  //--- Action Repo
  if(!contractAddr.history){
    //Deploy Action Repo
    let actionContract = await ethers.getContractFactory("ActionRepo").then(res => res.deploy(contractAddr.hub));
    await actionContract.deployed();
    //Set Address
    contractAddr.history = actionContract.address;
    //Log
    console.log("Deployed ActionRepo Contract to " + contractAddr.history);

    if(!!hubContract){  //If Deployed Together
      try{
        //Set to HUB
        hubContract.setAssoc("history", contractAddr.history);
      }
      catch(error){
        console.error("Failed to Set History Contract to Hub", error);
      }
    }
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
