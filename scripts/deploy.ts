// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

//Track Addresses (Fill in present addresses to prevent new deplopyment)
const contractAddr = {
  config:"0x14E5D5B68A41665E86225e6830a69bb2b5F6E484",  //V2
  case:"0x0785Bb55fA7dfbBAACd43C8b54527705BD8df5AD",  //Case Instance //V0.3
  hub:"0x731bAa306685d6db7e2a6bAAbe12cf8A874Bd16E", //V2
  avatar:"0x41966B4485CBd781fE9e82f90ABBA96958C096CF",  //V1
  history:"0x8b382adbfC940eae42AfC11eF389e5dA6597Fa06", //V4
  jurisdiction:"0x93Cb004fd336f9918d1198bA193e04B396925940", //V0.6
};

async function main() {

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

  //--- Case
  if(!contractAddr.case){
    //Deploy Case
    let hubContract = await ethers.getContractFactory("Case").then(res => res.deploy());
    await hubContract.deployed();
    //Set Address
    contractAddr.case = hubContract.address;
    //Log
    console.log("Deployed Case Contract to " + contractAddr.case);
  }

  //--- Hub
  if(!contractAddr.hub){
    //Deploy Hub
    let caseContract = await ethers.getContractFactory("Hub").then(res => res.deploy(contractAddr.config, contractAddr.case));
    await caseContract.deployed();
    //Set Address
    contractAddr.hub = caseContract.address;
    //Log
    console.log("Deployed Hub Contract to " + contractAddr.hub+ " Conf: "+ contractAddr.config+ " Case: "+ contractAddr.case);
  }

  //--- Avatar
  if(!contractAddr.avatar){
    //Deploy Avatar
    let avatarContract = await ethers.getContractFactory("AvatarNFT").then(res => res.deploy(contractAddr.hub));
    await avatarContract.deployed();
    //Set Address
    contractAddr.avatar = avatarContract.address;
    //Log
    console.log("Deployed Avatar Contract to " + contractAddr.avatar);
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
  }

  //--- Jurisdiction
  if(!contractAddr.jurisdiction){
    //Deploy Avatar
    // const JurisdictionContract = await ethers.getContractFactory("Jurisdiction");
    // let jurisdictionContract = await JurisdictionContract.deploy(contractAddr.hub, contractAddr.history);
    let jurisdictionContract = await ethers.getContractFactory("Jurisdiction").then(res => res.deploy(contractAddr.hub, contractAddr.history));
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