import { expect } from "chai";
import { Contract, ContractReceipt, Signer } from "ethers";
import { ethers } from "hardhat";

//Test Data
const ZERO_ADDR = '0x0000000000000000000000000000000000000000';
let test_uri = "ipfs://QmQxkoWcpFgMa7bCzxaANWtSt43J1iMgksjNnT4vM1Apd7"; //"TEST_URI";
let test_uri2 = "ipfs://TEST2";


describe("Protocol", function () {
  //Contract Instances
  let configContract: Contract;
  let hubContract: Contract;
  let avatarContract: Contract;
  let actionContract: Contract;
  let jurisdictionContract: Contract;
  // let jurisdictionUpContract: Contract;
  // let caseContract: Contract;

  //Addresses
  let owner: Signer;
  let admin: Signer;
  let tester: Signer;
  let tester2: Signer;
  let tester3: Signer;
  let tester4: Signer;
  let addrs: Signer[];


  before(async function () {
    //Deploy Config
    const ConfigContract = await ethers.getContractFactory("Config");
    configContract = await ConfigContract.deploy();

    //Deploy Case Implementation
    this.caseContract = await ethers.getContractFactory("Case").then(res => res.deploy());
    //Jurisdiction Upgradable Implementation
    this.jurisdictionUpContract = await ethers.getContractFactory("JurisdictionUpgradable").then(res => res.deploy());

    //Deploy Hub
    hubContract = await ethers.getContractFactory("Hub").then(res => res.deploy(configContract.address, this.jurisdictionUpContract.address, this.caseContract.address));

    /* Testing Rep Change Failure Recovery
    //Deploy a Second Hub
    let hubContract2 = await ethers.getContractFactory("Hub").then(res => res.deploy(configContract.address, this.jurisdictionUpContract.address, this.caseContract.address));
    avatarContract = await ethers.getContractFactory("AvatarNFT").then(res => res.deploy(hubContract2.address));
    */

    //Deploy Avatar
    avatarContract = await ethers.getContractFactory("AvatarNFT").then(res => res.deploy(hubContract.address));
    //Set Avatar Contract to Hub
    hubContract.setAssoc("avatar", avatarContract.address);

    //Deploy History
    actionContract = await ethers.getContractFactory("ActionRepo").then(res => res.deploy(hubContract.address));
    //Set Avatar Contract to Hub
    hubContract.setAssoc("history", actionContract.address);

    //Populate Accounts
    [owner, admin, tester, tester2, tester3, tester4, ...addrs] = await ethers.getSigners();
    //Addresses
    this.adminAddr = await admin.getAddress();
    this.testerAddr = await tester.getAddress();
    this.tester2Addr = await tester2.getAddress();
    this.tester3Addr = await tester3.getAddress();
    this.tester4Addr = await tester4.getAddress();
  });

  describe("Config", function () {

    it("Should be owned by deployer", async function () {
      expect(await configContract.owner()).to.equal(await owner.getAddress());
    });

  });

  describe("Avatar", function () {

    it("Should inherit protocol owner", async function () {
      expect(await avatarContract.owner()).to.equal(await owner.getAddress());
    });
    
    it("Can mint only one", async function () {
      let tx = await avatarContract.connect(tester).mint(test_uri);
      tx.wait();
      //Another One for Testing Purposes
      avatarContract.connect(tester2).mint(test_uri);
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

    it("Should Index Addresses", async function () {
      //Expected Token ID
      let tokenId = 1;
      //Fetch Token ID By Address
      let result = await avatarContract.tokenByAddress(this.testerAddr);
      //Check Token
      expect(result).to.equal(tokenId);
    });

    it("Allow Multiple Owner Accounts per Avatar", async function () {
      let miscAddr = await addrs[0].getAddress();
      let tokenId = 1;
      //Fetch Token ID By Address
      let tx = await avatarContract.tokenOwnerAdd(miscAddr, tokenId);
      tx.wait();
      //Expected Event
      await expect(tx).to.emit(avatarContract, 'Transfer').withArgs(ZERO_ADDR, miscAddr, tokenId);
      //Fetch Token For Owner
      let result = await avatarContract.tokenByAddress(miscAddr);
      //Validate
      expect(result).to.equal(tokenId);
    });

    // it("[TBD] Should Merge Avatars", async function () {

    // });

    it("Can add other people", async function () {
      // let test_uri = "TEST_URI_2";
      await avatarContract.connect(tester).add(test_uri);
      await avatarContract.connect(tester).add(test_uri);
      let tx = await avatarContract.connect(tester).add(test_uri);
      tx.wait();
      // console.log("minting", tx);
      //Fetch Token
      let result = await avatarContract.ownerOf(3);
      //Check Owner
      expect(result).to.equal(await avatarContract.address);
      //Check URI
      expect(await avatarContract.tokenURI(3)).to.equal(test_uri);
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

    /* BLOCKED FOR SECURITY REASONS
    it("Can collect rating", async function () {
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
    */

    it("Should protect from unauthorized reputation changes", async function () {
      //Rep Call Data      
      let repCall = { tokenId:1, domain:"personal", rating:1, amount:2};
      //Should Fail - Require Permissions
      await expect(
        avatarContract.repAdd(repCall.tokenId, repCall.domain, repCall.rating, repCall.amount)
      ).to.be.revertedWith("UNAUTHORIZED_ACCESS");
    });

  }); //Avatar

  /**
   * Action Repository
   */
  describe("Action Repository", function () {
  
    it("Should store Actions", async function () {
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
      // console.log("actionGUID:", actionGUID);

      //Expect Added Event
      await expect(tx).to.emit(actionContract, 'ActionAdded').withArgs(1, actionGUID, action.subject, action.verb, action.object, action.tool);
      // await expect(tx).to.emit(actionContract, 'URI').withArgs(actionGUID, uri);
      // await expect(tx).to.emit(actionContract, 'Confirmation');//.withArgs(actionGUID, confirmation);

      //Fetch Action's Struct
      let actionRet = await actionContract.actionGet(actionGUID);
      
      // console.log("actionGet:", actionRet);
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
      //Mint Avatars for Participants
      await avatarContract.connect(owner).mint(test_uri);
      await avatarContract.connect(admin).mint(test_uri);
      await avatarContract.connect(tester3).mint(test_uri);
      await avatarContract.connect(tester4).mint(test_uri);

      //Simulate to Get New Jurisdiction Address
      let JAddr = await hubContract.callStatic.jurisdictionMake("Test Jurisdiction", test_uri);
      // let JAddr = await hubContract.connect(admin).callStatic.jurisdictionMake("Test Jurisdiction", test_uri);

      //Create New Jurisdiction
      let tx = await hubContract.jurisdictionMake("Test Jurisdiction", test_uri);
      //Expect Valid Address
      expect(JAddr).to.be.properAddress;
      //Expect Case Created Event
      await expect(tx).to.emit(hubContract, 'ContractCreated').withArgs("jurisdiction", JAddr);
      //Init Jurisdiction Contract Object
      jurisdictionContract = await ethers.getContractFactory("JurisdictionUpgradable").then(res => res.attach(JAddr));
      this.jurisdictionContract = jurisdictionContract;
    });

    it("Should Update Contract URI", async function () {
      //Before
      expect(await this.jurisdictionContract.contractURI()).to.equal(test_uri);
      //Change
      await this.jurisdictionContract.setContractURI(test_uri2);
      //After
      expect(await this.jurisdictionContract.contractURI()).to.equal(test_uri2);
    });

    it("Users can join as a member", async function () {
      //Check Before
      expect(await this.jurisdictionContract.roleHas(this.testerAddr, "member")).to.equal(false);
      //Join Jurisdiction
      await this.jurisdictionContract.connect(tester).join();
      //Check After
      expect(await this.jurisdictionContract.roleHas(this.testerAddr, "member")).to.equal(true);
    });
    
    it("[TODO] Role Should Track Avatar Owner", async function () {
      

    });

    it("Users can leave", async function () {
      //Check Before
      expect(await this.jurisdictionContract.roleHas(this.testerAddr, "member")).to.equal(true);
      //Join Jurisdiction
      await this.jurisdictionContract.connect(tester).leave();
      //Check After
      expect(await this.jurisdictionContract.roleHas(this.testerAddr, "member")).to.equal(false);
    });

    it("Owner can appoint Admin", async function () {
      //Check Before
      expect(await this.jurisdictionContract.roleHas(this.adminAddr, "admin")).to.equal(false);
      //Should Fail - Require Permissions
      await expect(
        this.jurisdictionContract.connect(tester).roleAssign(this.adminAddr, "admin")
      ).to.be.revertedWith("INVALID_PERMISSIONS");
      //Assign Admin
      await this.jurisdictionContract.roleAssign(this.adminAddr, "admin");
      //Check After
      expect(await this.jurisdictionContract.roleHas(this.adminAddr, "admin")).to.equal(true);
    });

    it("Admin can appoint judge", async function () {
      let testerAddr = await tester.getAddress();
      //Check Before
      expect(await this.jurisdictionContract.roleHas(testerAddr, "judge")).to.equal(false);
      //Should Fail - Require Permissions
      await expect(
        this.jurisdictionContract.connect(tester2).roleAssign(testerAddr, "judge")
      ).to.be.revertedWith("INVALID_PERMISSIONS");
      //Assign Judge
      await this.jurisdictionContract.connect(admin).roleAssign(testerAddr, "judge");
      //Check After
      expect(await this.jurisdictionContract.roleHas(testerAddr, "judge")).to.equal(true);
    });
    
    it("Can change Roles (Promote / Demote)", async function () {
      //Check Before
      expect(await this.jurisdictionContract.roleHas(this.tester4Addr, "admin")).to.equal(false);
      //Join Jurisdiction
      let tx = await this.jurisdictionContract.connect(tester4).join();
      await tx.wait();
      //Check Before
      expect(await this.jurisdictionContract.roleHas(this.tester4Addr, "member")).to.equal(true);
      //Upgrade to Admin
      await this.jurisdictionContract.roleChange(this.tester4Addr, "member", "admin");
      //Check After
      expect(await this.jurisdictionContract.roleHas(this.tester4Addr, "admin")).to.equal(true);
    });
    
    it("Should store Rules", async function () {
      let actionGUID = '0xa7440c99ff5cd38fc9e0bff1d6dbf583cc757a83a3424bdc4f5fd6021a2e90e2';//await actionContract.callStatic.actionAdd(action);
      let confirmation = {
        ruling: "judge",  //Decision Maker
        evidence: true, //Require Evidence
        witness: 1,  //Minimal number of witnesses
      };
      let rule = {
        // uint256 about;    //About What (Token URI +? Contract Address)
        about: actionGUID, //"0xa7440c99ff5cd38fc9e0bff1d6dbf583cc757a83a3424bdc4f5fd6021a2e90e2",
        affected: "investor",  //Plaintiff / Beneficiary
        // about: 1,
        // string uri;     //Text, Conditions & additional data
        uri: "ADDITIONAL_DATA_URI",
        // Effect Object (Describes Changes to Rating By Type)
        /*
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
        */
        // bool negation;  //false - Commision  true - Omission
        negation: false,
      };
      let effects1 = [
        {name:'professional', value:5, direction:false},
        {name:'social', value:5, direction:true},
      ];
      let rule2 = {
        // uint256 about;    //About What (Token URI +? Contract Address)
        about: actionGUID, //"0xa7440c99ff5cd38fc9e0bff1d6dbf583cc757a83a3424bdc4f5fd6021a2e90e2",
        affected: "god",  //Plaintiff / Beneficiary
        // about: 1,
        // string uri;     //Text, Conditions & additional data
        uri: "ADDITIONAL_DATA_URI",
        // Effect Object (Describes Changes to Rating By Type)
        /* DEPRECATED
        effects:{
          // int8 environmental;
          environmental: -10,
          // int8 professional;
          professional: 0,
          // int8 social;
          social: 0,
          // int8 personal;
          personal: 0,
        },
        */
        // bool negation;  //false - Commision  true - Omission
        negation: false,
      };
      let  effects2 = [
        {name:'environmental', value:10, direction:false},
        {name:'personal', value:4, direction:true},
      ];
     
      //Add Rule
      let tx = await jurisdictionContract.connect(admin).ruleAdd(rule, confirmation, effects1);
      // wait until the transaction is mined
      await tx.wait();
      // console.log("Rule Added", tx);

      //Expect Event
      await expect(tx).to.emit(jurisdictionContract, 'Rule').withArgs(1, rule.about, rule.affected, rule.uri, rule.negation);
      // await expect(tx).to.emit(jurisdictionContract, 'RuleEffects').withArgs(1, rule.effects.environmental, rule.effects.personal, rule.effects.social, rule.effects.professional);
      for(let effect of effects1){
        await expect(tx).to.emit(jurisdictionContract, 'RuleEffect').withArgs(1, effect.direction, effect.value, effect.name);
      }
      await expect(tx).to.emit(jurisdictionContract, 'Confirmation').withArgs(1, confirmation.ruling, confirmation.evidence, confirmation.witness);

      //Add Another Rule
      let tx2 = await jurisdictionContract.connect(admin).ruleAdd(rule2, confirmation, effects2);
            
      //Expect Event
      await expect(tx2).to.emit(jurisdictionContract, 'Rule').withArgs(2, rule2.about, rule2.affected, rule2.uri, rule2.negation);
      // await expect(tx2).to.emit(jurisdictionContract, 'RuleEffects').withArgs(2, rule2.effects.environmental, rule2.effects.personal, rule2.effects.social, rule2.effects.professional);
      await expect(tx2).to.emit(jurisdictionContract, 'Confirmation').withArgs(2, confirmation.ruling, confirmation.evidence, confirmation.witness);

      // expect(await jurisdictionContract.ruleAdd(actionContract.address)).to.equal("Hello, world!");
      // let ruleData = await jurisdictionContract.ruleGet(1);
      
      // console.log("Rule Getter:", typeof ruleData, ruleData);   //some kind of object array crossbread
      // console.log("Rule Getter Effs:", ruleData.effects);  //V
      // console.log("Rule Getter:", JSON.stringify(ruleData)); //As array. No Keys
      
      // await expect(ruleData).to.include.members(Object.values(rule));
    });

    it("Should Update Rule", async function () {
      let actionGUID = '0xa7440c99ff5cd38fc9e0bff1d6dbf583cc757a83a3424bdc4f5fd6021a2e90e2';
      let rule = {
        about: actionGUID, //"0xa7440c99ff5cd38fc9e0bff1d6dbf583cc757a83a3424bdc4f5fd6021a2e90e2",
        affected: "god",  //Plaintiff / Beneficiary
        uri: "ADDITIONAL_DATA_URI",
        negation: false,
      };
      let  effects = [
        {name:'environmental', value:1, direction:false},
        {name:'personal', value:1, direction:true},
      ];
      let tx = await jurisdictionContract.connect(admin).ruleUpdate(2, rule, effects);

      // let curEffects = await jurisdictionContract.effectsGet(2);
      // console.log("Effects", curEffects);
      // expect(curEffects).to.include.members(Object.values(effects));    //Doesn't Work...

    });

    it("Should Update Token URI", async function () {
      //Protected
      await expect(
        jurisdictionContract.connect(tester3).setRoleURI("admin", test_uri)
      ).to.be.revertedWith("INVALID_PERMISSIONS");
      //Set Admin Token URI
      await jurisdictionContract.connect(admin).setRoleURI("admin", test_uri);
      //Validate
      expect(await jurisdictionContract.roleURI("admin")).to.equal(test_uri);
    });

  }); //Jurisdiction

  /**
   * Case Contract
   */
  describe("Case", function () {
    
    it("Should be Created (by Jurisdiction)", async function () {
      let caseName = "Test Case #1";
      let ruleRefArr = [
        {
          jurisdiction: jurisdictionContract.address, 
          ruleId: 1,
        }
      ];
      let roleRefArr = [
        {
          role: "subject",
          account: this.tester2Addr, 
        }
      ];
      let posts = [
        {
          entRole: "admin",
          // postRole: "evidence",
          uri: test_uri,
        }
      ];
      //Join Jurisdiction (as member)
      await jurisdictionContract.connect(admin).join();

      //Simulate - Get New Case Address
      let caseAddr = await jurisdictionContract.connect(admin).callStatic.caseMake(caseName, test_uri, ruleRefArr, roleRefArr, posts);
      // console.log("New Case Address: ", caseAddr);

      //Create New Case
      let tx = await jurisdictionContract.connect(admin).caseMake(caseName, test_uri, ruleRefArr, roleRefArr, posts);
      //Expect Valid Address
      expect(caseAddr).to.be.properAddress;
      //Init Case Contract
      this.caseContract = await ethers.getContractFactory("Case").then(res => res.attach(caseAddr));
      //Expect Case Created Event
      await expect(tx).to.emit(jurisdictionContract, 'CaseCreated').withArgs(1, caseAddr);
      //Expect Post Event
      await expect(tx).to.emit(this.caseContract, 'Post').withArgs(this.adminAddr, posts[0].entRole, posts[0].uri);
    });
    
    it("Should be Created & Opened (by Jurisdiction)", async function () {
    
      let caseName = "Test Case #1";
      let ruleRefArr = [
        {
          jurisdiction: jurisdictionContract.address, 
          ruleId: 1,
        }
      ];
      let roleRefArr = [
        {
          role: "subject",
          account: this.tester2Addr, 
        },
        {
          role: "witness",
          account: this.tester3Addr, 
        }
      ];
      let posts = [
        {
          entRole: "admin",
          // postRole: "evidence",
          uri: test_uri,
        }
      ];
      //Simulate - Get New Case Address
      let caseAddr = await jurisdictionContract.connect(admin).callStatic.caseMake(caseName, test_uri, ruleRefArr, roleRefArr, posts);
      //Create New Case
      let tx = await jurisdictionContract.connect(admin).caseMakeOpen(caseName, test_uri, ruleRefArr, roleRefArr, posts);
      //Expect Valid Address
      expect(caseAddr).to.be.properAddress;
      //Init Case Contract
      let caseContract = await ethers.getContractFactory("Case").then(res => res.attach(caseAddr));
      //Expect Case Created Event
      await expect(tx).to.emit(jurisdictionContract, 'CaseCreated').withArgs(2, caseAddr);
      //Expect Post Event
      // await expect(tx).to.emit(caseContract, 'Post').withArgs(this.adminAddr, posts[0].entRole, posts[0].postRole, posts[0].uri);
      await expect(tx).to.emit(caseContract, 'Post').withArgs(this.adminAddr, posts[0].entRole, posts[0].uri);
    });

    it("Should Update Contract URI", async function () {
      //Before
      expect(await this.caseContract.contractURI()).to.equal(test_uri);
      //Change
      await this.caseContract.setContractURI(test_uri2);
      //After
      expect(await this.caseContract.contractURI()).to.equal(test_uri2);
    });

    it("Should Auto-Appoint creator as Admin", async function () {
      expect(await this.caseContract.roleHas(this.adminAddr, "admin")).to.equal(true);
    });

    it("Tester expected to be in the subject role", async function () {
      expect(await this.caseContract.roleHas(this.tester2Addr, "subject")).to.equal(true);
    });

    it("Should Update", async function () {

      let testCaseContract = await ethers.getContractFactory("Case").then(res => res.deploy());
      await testCaseContract.deployed();
      //Update Case Beacon (to the same implementation)
      hubContract.upgradeCaseImplementation(testCaseContract.address);
    });

    it("Should Add Rules", async function () {
      let ruleRef = {
        jurisdiction: jurisdictionContract.address, 
        id: 2, 
        // affected: "investor",
      };
      // await this.caseContract.ruleAdd(ruleRef.jurisdiction,  ruleRef.id, ruleRef.affected);
      await this.caseContract.connect(admin).ruleAdd(ruleRef.jurisdiction,  ruleRef.id);
    });
    
    it("Should Post", async function () {
      let post = {
        entRole:"subject",
        uri:test_uri,
      }
      //Post
      let tx = await this.caseContract.connect(tester2).post(post.entRole, post.uri);
      // wait until the transaction is mined
      await tx.wait();
      //Expect Event
      await expect(tx).to.emit(this.caseContract, 'Post').withArgs(this.tester2Addr, post.entRole, post.uri);
    });

    it("Should Update Token URI", async function () {
      //Protected
      await expect(
        this.caseContract.connect(tester3).setRoleURI("admin", test_uri)
      ).to.be.revertedWith("INVALID_PERMISSIONS");

      //Set Admin Token URI
      await this.caseContract.connect(admin).setRoleURI("admin", test_uri);
      //Validate
      expect(await this.caseContract.roleURI("admin")).to.equal(test_uri);
    });

    it("Should Assign Witness", async function () {
          //Assign Admin
          await this.caseContract.connect(admin).roleAssign(this.tester3Addr, "witness");
          //Validate
          expect(await this.caseContract.roleHas(this.tester3Addr, "witness")).to.equal(true);
    });

    it("Plaintiff Can Open Case", async function () {
      //Validate
      await expect(
        this.caseContract.connect(tester2).stageFile()
      ).to.be.revertedWith("ROLE:PLAINTIFF_OR_ADMIN");
      //File Case
      let tx = await this.caseContract.connect(admin).stageFile();
      //Expect State Event
      await expect(tx).to.emit(this.caseContract, 'Stage').withArgs(1);
    });

    it("Should Wait for Verdict Stage", async function () {
      //File Case
      let tx = await this.caseContract.connect(tester2).stageWaitForVerdict();
      //Expect State Event
      await expect(tx).to.emit(this.caseContract, 'Stage').withArgs(2);
    });

    it("Should Wait for judge", async function () {
      let verdict = [{ ruleId:1, decision: true }];
      //File Case -- Expect Failure
      await expect(
        this.caseContract.connect(tester2).stageVerdict(verdict, test_uri)
      ).to.be.revertedWith("ROLE:JUDGE_ONLY");
    });

    it("Should Validate Judge with parent jurisdiction", async function () {
      //Validate
      await expect(
        this.caseContract.connect(admin).roleAssign(this.tester3Addr, "judge")
      ).to.be.revertedWith("User Required to hold same role in Jurisdiction");
    });

    it("Should Accept a Judge From the parent jurisdiction", async function () {
      //Check Before
      // expect(await this.jurisdictionContract.roleHas(this.testerAddr, "judge")).to.equal(true);
      //Assign Judge
      await this.caseContract.connect(admin).roleAssign(this.testerAddr, "judge");
      //Check After
      expect(await this.caseContract.roleHas(this.testerAddr, "judge")).to.equal(true);
    });
    
    it("Should Accept Verdict URI & Close Case", async function () {
      let verdict = [{ruleId:1, decision:true}];
      //Submit Verdict & Close Case
      let tx = await this.caseContract.connect(tester).stageVerdict(verdict, test_uri);
      //Expect Verdict Event
      await expect(tx).to.emit(this.caseContract, 'Verdict').withArgs(test_uri, this.testerAddr);
      //Expect State Event
      await expect(tx).to.emit(this.caseContract, 'Stage').withArgs(6);


      //[DEBUG]
      // console.log(tx);
      // let receipt = await tx.wait();
      // console.log("Emited "+receipt.events.length+" Events", receipt.events);



    });

    
    it("[TODO] Can Change Rating", async function () {
      
      //TODO: Tests for Collect Rating
      // let repCall = { tokenId:?, domain:?, rating:?};
      // let result = this.jurisdictionContract.getRepForDomain(avatarContract.address,repCall. tokenId, repCall.domain, repCall.rating);

      // //Expect Event
      // await expect(tx).to.emit(avatarContract, 'ReputationChange').withArgs(repCall.tokenId, repCall.domain, repCall.rating, repCall.amount);

      //Validate State
      // getRepForDomain(address contractAddr, uint256 tokenId, string domain, bool rating) public view override returns (uint256){

      // let rep = await avatarContract.getRepForDomain(repCall.tokenId, repCall.domain, repCall.rating);
      // expect(rep).to.equal(repCall.amount);

      // //Other Domain Rep - Should be 0
      // expect(await avatarContract.getRepForDomain(repCall.tokenId, repCall.domain + 1, repCall.rating)).to.equal(0);

    });

  }); //Case
    
});
