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
  let actionContract: Contract;
  let caseContract: Contract;

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

      //Deploy Case Implementation
      this.caseContract = await ethers.getContractFactory("Case").then(res => res.deploy());

      //Deploy Hub
      // const HubContract = await ethers.getContractFactory("Hub");
      // hubContract = await HubContract.deploy(configContract.address);
      hubContract = await ethers.getContractFactory("Hub").then(res => res.deploy(configContract.address, this.caseContract.address));

      //Deploy Avatar
      // const AvatarContract = await ethers.getContractFactory("AvatarNFT");
      // avatarContract = await AvatarContract.deploy(hubContract.address);
      avatarContract = await ethers.getContractFactory("AvatarNFT").then(res => res.deploy(hubContract.address));

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
      let test_uri = "ipfs://QmQxkoWcpFgMa7bCzxaANWtSt43J1iMgksjNnT4vM1Apd7"; //"TEST_URI";

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
    
  }); //Avatar



  /**
   * Action Repository
   */
  describe("Action Repository", function () {
  
    before(async function () {
      //Deploy Action Repo / History Contract
      // const ActionContract = await ethers.getContractFactory("ActionRepo");
      // actionContract = await ActionContract.deploy(hubContract.address);
      actionContract = await ethers.getContractFactory("ActionRepo").then(res => res.deploy(hubContract.address));
    });
  
    it("Should store Actions", async function () {

      // let dataObj = ethers.utils.hexlify({ length: 2, "0": 1, "1": 2 });
      // let arrObj = ethers.utils.hexlify([1, 2, 3, 4]);
      // console.warn("*** dataObj: ", dataObj, ethers.utils.arrayify(dataObj));
      // console.warn("*** arrObj: ", arrObj, ethers.utils.arrayify(arrObj));

      let action = {
        subject: "founder",     //Accused Role
        verb: "breach",
        object: "contract",
        tool: "",
        
      };
      // let confirmation = {
      //   ruling: "judge",  //Decision Maker
      //   evidence: true, //Require Evidence
      //   witness: 1,  //Minimal number of witnesses
      // };
      let uri = "TEST_URI";

      // let actionGUID = '0xa7440c99ff5cd38fc9e0bff1d6dbf583cc757a83a3424bdc4f5fd6021a2e90e2';//await actionContract.callStatic.actionAdd(action);
      // let actionGUID = await actionContract.callStatic.actionAdd(action); //Simulate
      // let tx = await actionContract.actionAdd(action, confirmation, uri);
      let tx = await actionContract.actionAdd(action, uri);
      await tx.wait();

      let actionGUID = await actionContract.actionHash(action); //Gets hash if exists or not
      console.warn("actionGUID:", actionGUID);

      //Expect Added Event
      await expect(tx).to.emit(actionContract, 'ActionAdded').withArgs(1, actionGUID, action.subject, action.verb, action.object, action.tool);
      // await expect(tx).to.emit(actionContract, 'URI').withArgs(actionGUID, uri);
      // await expect(tx).to.emit(actionContract, 'Confirmation');//.withArgs(actionGUID, confirmation);

      //Fetch Action's Struct
      let actionRet = await actionContract.actionGet(actionGUID);
      
      
      // console.warn("actionGet:", actionRet);
      // expect(Object.values(actionRet)).to.eql(Object.values(action));
      expect(actionRet).to.include.members(Object.values(action));
      // expect(actionRet).to.eql(action);  //Fails
      // expect(actionRet).to.include(action); //Fails
      // expect(actionRet).to.own.include(action); //Fails

      //Additional Rule Data
      expect(await actionContract.actionGetURI(actionGUID)).to.equal(uri);
      // expect(await actionContract.actionGetConfirmation(actionGUID)).to.include.members(["judge", true]);    //TODO: Find a better way to check this
      
    });

  }); //Action Repository

  /**
   * Jurisdiction Contract
   */
  describe("Jurisdiction", function () {
    
    before(async function () {
        //Deploy Jurisdiction
        const JurisdictionContract = await ethers.getContractFactory("Jurisdiction");
        jurisdictionContract = await JurisdictionContract.deploy(hubContract.address, actionContract.address);

        //TODO: Write it more like this
        this.jurisdiction = jurisdictionContract;
        // console.log("jurisdiction: ", this.jurisdiction);
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
      this.adminAddr = adminAddr;

      //Check Before
      expect(await jurisdictionContract.roleHas(testerAddr, "judge")).to.equal(false);

      //Should Fail - Require Permissions
      await expect(
        jurisdictionContract.connect(tester2).roleAssign(testerAddr, "judge")
      ).to.be.revertedWith("INVALID_PERMISSIONS");
      
      //Assign Judge
      await jurisdictionContract.connect(admin).roleAssign(testerAddr, "judge");

      //Check After
      expect(await jurisdictionContract.roleHas(testerAddr, "judge")).to.equal(true);

    });
    
    it("Should store Rules", async function () {
      let actionGUID = '0xa7440c99ff5cd38fc9e0bff1d6dbf583cc757a83a3424bdc4f5fd6021a2e90e2';//await actionContract.callStatic.actionAdd(action);
      let rule = {
        // uint256 about;    //About What (Token URI +? Contract Address)
        about: actionGUID, //"0xa7440c99ff5cd38fc9e0bff1d6dbf583cc757a83a3424bdc4f5fd6021a2e90e2",
        affected: "investor",  //Plaintiff / Beneficiary
        // about: 1,
        // string uri;     //Text, Conditions & additional data
        uri: "ADDITIONAL_DATA_URI",
        // Effect Object (Describes Changes to Reputation By Type)
        effects:{
          // int8 environmental;
          environmental: 0,
          // int8 professional;
          professional: -5,
          // int8 social;
          social: 5,
          // int8 personal;
          personal: 0,
        },
        // bool negation;  //false - Commision  true - Omission
        negation: false,
      };
      let confirmation = {
        ruling: "judge",  //Decision Maker
        evidence: true, //Require Evidence
        witness: 1,  //Minimal number of witnesses
      };


      let tx = await jurisdictionContract.connect(admin).ruleAdd(rule, confirmation);
      // wait until the transaction is mined
      await tx.wait();
      // console.log("Rule Added", tx);

      //Expect Event
      await expect(tx).to.emit(jurisdictionContract, 'Rule').withArgs(1, rule.about, rule.affected, rule.uri, rule.negation);
      await expect(tx).to.emit(jurisdictionContract, 'RuleEffects').withArgs(1, rule.effects.environmental, rule.effects.personal, rule.effects.social, rule.effects.professional);
      await expect(tx).to.emit(jurisdictionContract, 'Confirmation').withArgs(1, confirmation.ruling, confirmation.evidence, confirmation.witness);

      // expect(await jurisdictionContract.ruleAdd(actionContract.address)).to.equal("Hello, world!");
      let ruleData = await jurisdictionContract.ruleGet(1);
      
      // console.log("Rule Getter:", typeof ruleData, ruleData);   //some kind of object array crossbread
      // console.log("Rule Getter Effs:", ruleData.effects);  //V
      // console.log("Rule Getter:", JSON.stringify(ruleData)); //As array. No Keys
      
      // await expect(ruleData).to.include.members(Object.values(rule));

    });
    

  }); //Jurisdiction


 /**
   * Case Contract
   */
  describe("Case", function () {
    

    it("Should be Created (by Jurisdiction)", async function () {
    
      let caseName = "Test Case #1";
      // let affected = "investor";

      // actionContract = await ethers.getContractFactory("Case").then(res => res.deploy(hubContract.address));

      let tx = await jurisdictionContract.connect(admin).caseMake(caseName);

      let caseAddr = await jurisdictionContract.getCaseById(1);
      expect(caseAddr).to.be.properAddress;
      
      //Case Contract
      this.caseContract = await ethers.getContractFactory("Case").then(res => res.attach(caseAddr));

      // console.log("case", this.caseContract);
      // console.log("jurisdiction's Make Case TX:", tx);
      // console.log("jurisdiction's Case #1:", caseAddr);
      
      //Expect Event
      await expect(tx).to.emit(jurisdictionContract, 'CaseCreated').withArgs(1, caseAddr);
    });

    it("Should Auto-Appoint creator as Admin", async function () {
      let adminAddr = await admin.getAddress();
      //Check
      expect(await this.caseContract.roleHas(adminAddr, "admin")).to.equal(true);
    });

    it("Should Add Rules", async function () {

      
      // let roleMapping = [
      //   {subject:"investor"}
      // ];
      let rule = {
        jurisdiction: jurisdictionContract.address, 
        id: 1, 
        affected: "investor",
        // affected: {
        //   account: 
        //   id: 
        //   chain: 
        // }
      };
      await this.caseContract.ruleAdd(rule.jurisdiction,  rule.id, rule.affected);

    });


  }); //Case
    
});
