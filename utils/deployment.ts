import { run } from "hardhat";
// import { ethers } from "hardhat";
// const { upgrades } = require("hardhat");
// import { deployments, ethers } from "hardhat"
// export const deployRepoRules = async (contractAddress: string, args: any[]) => {
// }

export const verify = async (contractAddress: string, args: any[]) => {
  console.log("Verifying contract...")
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    })
  } catch (e: any) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Already verified!")
    } else {
      console.log(e)
    }
  }
}



