import { expect } from "chai";
import { Contract, ContractReceipt, Signer } from "ethers";
import { ethers } from "hardhat";

/* Example
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
*/

describe("Protocol", function () {
  //Contract Instances
  let configContract: Contract;
  let hubContract: Contract;
  let avatarContract: Contract;
  let jurisdictionContract: Contract;

  //Addresses
  let owner: Signer;
  let admin: Signer;
  let tester: Signer;
  let tester2: Signer;
  let tester3: Signer;
  let addrs: Signer[];


  before(async function () {
      //Deploy Config
      const ConfigContract = await ethers.getContractFactory("Config");
      configContract = await ConfigContract.deploy();

      //Deploy Hub
      const HubContract = await ethers.getContractFactory("Hub");
      hubContract = await HubContract.deploy(configContract.address);

      //Deploy Avatar
      const AvatarContract = await ethers.getContractFactory("AvatarNFT");
      avatarContract = await AvatarContract.deploy(hubContract.address);

      //Populate Accounts
      [owner, admin, tester, tester2, tester3, ...addrs] = await ethers.getSigners();
  })

  describe("Config", function () {

    it("Should be owned by deployer", async function () {
      expect(await configContract.owner()).to.equal(await owner.getAddress());
    });

  });

  describe("Avatar", function () {

    it("Can inherit owner", async function () {
      expect(await avatarContract.owner()).to.equal(await owner.getAddress());
    });
    
    it("Can mint only one", async function () {
      let test_uri = "TEST_URI";

      let tx = await avatarContract.connect(tester).mint(test_uri);
      tx.wait();
      // console.log("minting", tx);
      //Fetch Token
      let result = await avatarContract.ownerOf(1);
      //Check Owner
      expect(result).to.equal(await tester.getAddress());
      //Check URI
      expect(await avatarContract.tokenURI(1)).to.equal(test_uri);

      //Another Call Should Fail
      await expect(
        avatarContract.connect(tester).mint(test_uri)
      ).to.be.revertedWith("Requesting account already has an avatar");
    });

    
    it("Can add other people", async function () {
      let test_uri = "TEST_URI_2";

      let tx = await avatarContract.connect(tester).add(test_uri);
      tx.wait();
      // console.log("minting", tx);
      //Fetch Token
      let result = await avatarContract.ownerOf(2);
      //Check Owner
      expect(result).to.equal(await avatarContract.address);
      //Check URI
      expect(await avatarContract.tokenURI(2)).to.equal(test_uri);
    });


    it("Should NOT be transferable", async function () {
      //Should Fail to transfer -- "Sorry, Assets are non-transferable"
      let fromAddr = await tester.getAddress();
      let toAddr = await tester2.getAddress();
      await expect(
        avatarContract.connect(tester).transferFrom(fromAddr, toAddr, 1)
      ).to.be.revertedWith("Sorry, Assets are non-transferable");
    });

    it("Can update token's metadata", async function () {
      let test_uri = "TEST_URI_UPDATED";
      //Update URI
      await avatarContract.connect(tester).update(1, test_uri);
      //Check URI
      expect(await avatarContract.connect(tester).tokenURI(1)).to.equal(test_uri);
    });

    it("Can collect reputation", async function () {
      //Rep Call Data      
      let repCall = { tokenId:1, domain:1, rating:1, amount:2};
      let tx = await avatarContract.repAdd(repCall.tokenId, repCall.domain, repCall.rating, repCall.amount);

      //Expect Event
      await expect(tx).to.emit(avatarContract, 'ReputationChange').withArgs(repCall.tokenId, repCall.domain, repCall.rating, repCall.amount);

      //Validate State
      let rep = await avatarContract.getRepForDomain(repCall.tokenId, repCall.domain, repCall.rating);
      expect(rep).to.equal(repCall.amount);

      //Other Domain Rep - Should be 0
      expect(await avatarContract.getRepForDomain(repCall.tokenId, repCall.domain + 1, repCall.rating)).to.equal(0);
    });
    
  });

  describe("Jurisdiction", function () {
    
    before(async function () {
        //Deploy Jurisdiction
        const JurisdictionContract = await ethers.getContractFactory("Jurisdiction");
        jurisdictionContract = await JurisdictionContract.deploy(hubContract.address);
    });

    it("Users can join as a member", async function () {

      let testerAddr = await tester.getAddress();

      //Check Before
      expect(await jurisdictionContract.roleHas(testerAddr, "member")).to.equal(false);

      //Join Jurisdiction
      await jurisdictionContract.connect(tester).join();

      //Check After
      expect(await jurisdictionContract.roleHas(testerAddr, "member")).to.equal(true);
    });

    it("Owner can appoint Admin", async function () {
      // let testerAddr = await tester.getAddress();
      let adminAddr = await admin.getAddress();

      //Check Before
      expect(await jurisdictionContract.roleHas(adminAddr, "admin")).to.equal(false);

      //Should Fail - Require Permissions
      await expect(
        jurisdictionContract.connect(tester).roleAssign(adminAddr, "admin")
      ).to.be.revertedWith("INVALID_PERMISSIONS");
      
      //Assign Admin
      await jurisdictionContract.roleAssign(adminAddr, "admin");

      //Check After
      expect(await jurisdictionContract.roleHas(adminAddr, "admin")).to.equal(true);
    });

    it("Admin can appoint judge", async function () {

      let testerAddr = await tester.getAddress();
      let adminAddr = await admin.getAddress();

      //Check Before
      expect(await jurisdictionContract.roleHas(testerAddr, "judge")).to.equal(false);

      //Should Fail - Require Permissions
      await expect(
        jurisdictionContract.connect(tester2).roleAssign(testerAddr, "judge")
      ).to.be.revertedWith("INVALID_PERMISSIONS");
      
      //Assign Admin
      await jurisdictionContract.connect(admin).roleAssign(testerAddr, "judge");

      //Check After
      expect(await jurisdictionContract.roleHas(testerAddr, "judge")).to.equal(true);

    });
    
  });

});
