import { expect } from "chai";
import { ethers } from "hardhat";

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});


describe("Avatar", function () {
  //Contract Instances
  let avatarContract;
  //Addresses
  let owner;
  let admin;
  let tester;
  let addrs;


  before(async function () {
      //Deploy
      const AvatarContract = await ethers.getContractFactory("AvaterNFT");
      avatarContract = await AvatarContract.deploy();
      //Populate Accounts
      [owner, admin, tester, ...addrs] = await ethers.getSigners();
  })

  // it("Should ...", async function () {
    
    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  // });

});
