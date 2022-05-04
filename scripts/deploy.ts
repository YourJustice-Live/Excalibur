// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

//Track Addresses (Fill in present addresses to prevent new deplopyment)
const contractAddr = {
  config:"0x14E5D5B68A41665E86225e6830a69bb2b5F6E484",  //V2.0
  case:"0x500a7f031571848e32490444c33d513F1a7c8e9b",  //Case Instance //V1.11
  hub:"0xce92b64ba4b9a2905605c8c04e9F1e27C5D6E559", //V2.1
  avatar:"0xE7254468763a8d4f791f30F5e8dcA635DF850772",  //V1.1
  history:"0xe699f8dd6968F7a60786E846899CEf56154D3573", //V4.0
  jurisdiction:"0x22A339004E2a005ED5D5b94C83EEA2E47BE249EB", //V1.0
};

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

  //--- Case
  if(!contractAddr.case){
    //Deploy Case
    hubContract = await ethers.getContractFactory("Case").then(res => res.deploy());
    await hubContract.deployed();
    //Set Address
    contractAddr.case = hubContract.address;
    //Log
    console.log("Deployed Case Contract to " + contractAddr.case);
  }

  //--- Hub
  if(!contractAddr.hub){
    //Deploy Hub
    let caseContract = await ethers.getContractFactory("Hub").then(res => res.deploy(
        contractAddr.config, 
        // contractAddr.avatar, 
        contractAddr.case,
      ));
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

    if(!!hubContract){  //If Deployed Together
      try{
        //Set to HUB
        hubContract.setAvatarContract(contractAddr.avatar);
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
  }

  //--- Jurisdiction
  if(!contractAddr.jurisdiction){
    //Deploy Jurisdiction
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
