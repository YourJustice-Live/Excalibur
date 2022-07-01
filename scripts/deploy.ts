// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
const {  upgrades } = require("hardhat");
const hre = require("hardhat");
const chain = hre.hardhatArguments.network;

//Track Addresses (Fill in present addresses to prevent new deplopyment)
import contractAddrs from "./_contractAddr";
const contractAddr = contractAddrs[chain];
import publicAddrs from "./_publicAddrs";
const publicAddr = publicAddrs[chain];

async function main() {

  console.log("Running on Chain: ", chain);

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

  //--- TEST: Upgradable Hub
  if(!contractAddr.hub){
    //Deploy Hub Upgradable (UUDP)    
    hubContract = await ethers.getContractFactory("HubUpgradable").then(Contract => 
      upgrades.deployProxy(Contract,
        [
          publicAddr.openRepo,
          contractAddr.config, 
          contractAddr.jurisdiction,
          contractAddr.case,
        ],{
        kind: "uups",
        timeout: 120000
      })
    );

    await hubContract.deployed();

    //Set Address
    contractAddr.hub = hubContract.address;

    console.log("HubUpgradable deployed to:", hubContract.address);

    try{
      //Set as Avatars
      if(!!contractAddr.avatar) await hubContract.setAssoc("avatar", contractAddr.avatar);
      //Set as History
      if(!!contractAddr.history) await hubContract.setAssoc("history", contractAddr.history);
    }
    catch(error){
      console.error("Failed to Set Contracts to Hub", error);
    }

    //Log
    console.log("Deployed Hub Upgradable Contract to " + contractAddr.hub+ " Conf: "+ contractAddr.config+ " jurisdiction: "+contractAddr.jurisdiction+ " Case: "+ contractAddr.case);
    console.log("Run: npx hardhat verify --network rinkeby " + contractAddr.hub+" "+publicAddr.openRepo+" "+ contractAddr.config+" "+contractAddr.jurisdiction+ " "+contractAddr.case);
  }

  //--- Avatar Upgradable
  if(!contractAddr.avatar){

    //Deploy Avatar Upgradable
    const proxyAvatar = await ethers.getContractFactory("SoulUpgradable").then(Contract => 
      upgrades.deployProxy(Contract,
        [contractAddr.hub],{
        kind: "uups",
        timeout: 120000
      })
    );

    await proxyAvatar.deployed();
    contractAddr.avatar = proxyAvatar.address;
    
    //Log
    console.log("Deployed Avatar Proxy Contract to " + contractAddr.avatar);
    // console.log("Run: npx hardhat verify --network rinkeby "+contractAddr.avatar);
    if(!!hubContract){  //If Deployed Together
      try{
        //Set to HUB
        await hubContract.setAssoc("avatar", contractAddr.avatar);
        //Log
        console.log("Registered Avatar Contract to Hub");
      }
      catch(error){
        console.error("Failed to Set Avatar Contract to Hub", error);
      }
    }
  }

  //--- Action Repo
  if(!contractAddr.history){

    /* DEPRECAETD - Non-Upgradable
    //Deploy Action Repo
    let actionContract = await ethers.getContractFactory("ActionRepo").then(res => res.deploy(contractAddr.hub));
    await actionContract.deployed();
    //Set Address
    contractAddr.history = actionContract.address;
    */

    console.log("BEFORE History Contract Deployment");

    //Deploy History Upgradable (UUDP)
    const proxyActionRepo = await ethers.getContractFactory("ActionRepoTrackerUp").then(Contract => 
      upgrades.deployProxy(Contract,
        [contractAddr.hub],{
        kind: "uups",
        timeout: 120000
      })
    );
    await proxyActionRepo.deployed();
    
    console.log("Deployed History Contract", proxyActionRepo.address);

    //Set Address
    contractAddr.history = proxyActionRepo.address;
    //Log
    console.log("Deployed ActionRepo Contract to " + contractAddr.history);

    if(!!hubContract){  //If Deployed Together
      try{
        //Log
        console.log("Will Register History to Hub");

        //Set to HUB
        await hubContract.setAssoc("history", contractAddr.history);
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
