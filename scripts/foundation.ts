import { ethers } from "hardhat";
const { upgrades } = require("hardhat");
const hre = require("hardhat");
const chain = hre.hardhatArguments.network;

// Track Addresses (fill in present addresses to prevent new deplopyment)
import publicAddrs from "./_publicAddrs";
const publicAddr = publicAddrs[chain];

/**
 * Deploy Independent Public Agents
 */
async function main() {
  //--- Open Repo
  if (!publicAddr.openRepo) {
    // Deploy OpenRepo Upgradable (UUDP)
    let contractInstance = await ethers
      .getContractFactory("OpenRepoUpgradable")
      .then((Contract) =>
        upgrades.deployProxy(Contract, [], {
          kind: "uups",
          timeout: 120000,
        })
      );
    // Set Address
    publicAddr.openRepo = contractInstance.address;
    // Log
    console.log(
      "Deployed OpenRepo Contract to Chain: " +
        chain +
        " Address: " +
        contractInstance.address
    );
    console.log(
      "Run: npx hardhat verify --network " +
        chain +
        " " +
        contractInstance.address
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
