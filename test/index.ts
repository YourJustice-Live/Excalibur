import { expect } from "chai";
import { Contract, Signer } from "ethers";
import { ethers } from "hardhat";
import { deployContract, deployUUPS } from "../utils/deployment";
const { upgrades } = require("hardhat");

//Test Data
const ZERO_ADDR = '0x0000000000000000000000000000000000000000';
let test_uri = "ipfs://QmQxkoWcpFgMa7bCzxaANWtSt43J1iMgksjNnT4vM1Apd7"; //"TEST_URI";
let test_uri2 = "ipfs://TEST2";
let actionGUID = "";

describe("Protocol", function () {
  //Contract Instances
  let configContract: Contract;
  let hubContract: Contract;
  let avatarContract: Contract;
  let actionContract: Contract;
  let gameContract: Contract;
  let unOwnedTokenId: number;

  //Addresses
  let owner: Signer;
  let admin: Signer;
  let tester: Signer;
  let tester2: Signer;
  let tester3: Signer;
  let tester4: Signer;
  let tester5: Signer;
  let authority: Signer;
  let addrs: Signer[];


  before(async function () {
    //Deploy Config
    // const ConfigContract = await ethers.getContractFactory("Config");
    // configContract = await ConfigContract.deploy();
    configContract = await ethers.getContractFactory("Config").then(res => res.deploy());

    //--- Deploy OpenRepo Upgradable (UUPS)
    // this.openRepo = await ethers.getContractFactory("OpenRepoUpgradable")
    //   .then(Contract => upgrades.deployProxy(Contract, [],{kind: "uups", timeout: 120000}));
    this.openRepo = await deployUUPS("OpenRepoUpgradable", []);

    //--- Deploy Incident Implementation
    this.incidentContract = await ethers.getContractFactory("IncidentUpgradable").then(res => res.deploy());

    //--- Deploy Game Implementation
    this.gameUpContract = await ethers.getContractFactory("GameUpgradable").then(res => res.deploy());

    //Deploy Hub
    // hubContract = await ethers.getContractFactory("Hub").then(res => res.deploy(configContract.address, this.gameUpContract.address, this.incidentContract.address));

    //--- Deploy Hub Upgradable (UUPS)
    hubContract = await deployUUPS("HubUpgradable", 
      [
        this.openRepo.address,
        configContract.address, 
        this.gameUpContract.address, 
        this.incidentContract.address
      ]);
    // await hubContract.deployed();


    //--- Rule Repository
    //Deploy
    this.ruleRepo = await deployContract("RuleRepo", []);
    //Set to Hub
    hubContract.setAssoc("RULE_REPO", this.ruleRepo.address);

    //--- Deploy Soul Upgradable (UUPS)
    avatarContract = await deployUUPS("SoulUpgradable", [hubContract.address]);

    //Set Avatar Contract to Hub
    hubContract.setAssoc("avatar", avatarContract.address);

    //Deploy History
    // actionContract = await ethers.getContractFactory("ActionRepo").then(res => res.deploy(hubContract.address));

    //--- Deploy History Upgradable (UUPS)
    actionContract = await ethers.getContractFactory("ActionRepoTrackerUp").then(Contract => 
      upgrades.deployProxy(Contract,
        [hubContract.address],{
        // https://docs.openzeppelin.com/upgrades-plugins/1.x/api-hardhat-upgrades#common-options
        kind: "uups",
        timeout: 120000
      })
    );

    //Set Avatar Contract to Hub
    hubContract.setAssoc("history", actionContract.address);

    //Populate Accounts
    [owner, admin, tester, tester2, tester3, tester4, tester5, authority, ...addrs] = await ethers.getSigners();
    //Addresses
    this.ownerAddr = await owner.getAddress();
    this.adminAddr = await admin.getAddress();
    this.testerAddr = await tester.getAddress();
    this.tester2Addr = await tester2.getAddress();
    this.tester3Addr = await tester3.getAddress();
    this.tester4Addr = await tester4.getAddress();
    this.tester5Addr = await tester5.getAddress();
    this.authorityAddr = await authority.getAddress();
  });

  describe("Config", function () {

    it("Should be owned by deployer", async function () {
      expect(await configContract.owner()).to.equal(await owner.getAddress());
    });

  });

  describe("OpenRepo", function () {

    it("Should Get Empty Value", async function () {
      //Change to Closed Game
      await this.openRepo.stringGet("TestKey");
      await this.openRepo.boolGet("TestKey");
      await this.openRepo.addressGet("TestKey");
    });

  });

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

      // actionGUID = '0xa7440c99ff5cd38fc9e0bff1d6dbf583cc757a83a3424bdc4f5fd6021a2e90e2'; //Wrong GUID
      actionGUID = await actionContract.actionHash(action); //Gets hash if exists or not
      // console.log("actionGUID:", actionGUID);
      let tx = await actionContract.actionAdd(action, test_uri);
      await tx.wait();
      //Expect Added Event
      await expect(tx).to.emit(actionContract, 'ActionAdded').withArgs(1, actionGUID, action.subject, action.verb, action.object, action.tool);
      // await expect(tx).to.emit(actionContract, 'URI').withArgs(actionGUID, test_uri);

      //Fetch Action's Struct
      let actionRet = await actionContract.actionGet(actionGUID);
      
      // console.log("actionGet:", actionRet);
      // expect(Object.values(actionRet)).to.eql(Object.values(action));
      expect(actionRet).to.include.members(Object.values(action));
      // expect(actionRet).to.eql(action);  //Fails
      // expect(actionRet).to.include(action); //Fails
      // expect(actionRet).to.own.include(action); //Fails

      //Additional Rule Data
      expect(await actionContract.actionGetURI(actionGUID)).to.equal(test_uri);
      // expect(await actionContract.actionGetConfirmation(actionGUID)).to.include.members(["authority", true]);    //TODO: Find a better way to check this
    });

  }); //Action Repository

  describe("Soul", function () {

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
      unOwnedTokenId = await avatarContract.connect(tester).callStatic.add(test_uri);
      await avatarContract.connect(tester).add(test_uri);
      await avatarContract.connect(tester).add(test_uri);
      let tx = await avatarContract.connect(tester).add(test_uri);
      tx.wait();
      // console.log("minting", tx);
      //Fetch Token
      let result = await avatarContract.ownerOf(unOwnedTokenId);
      //Check Owner
      expect(result).to.equal(await avatarContract.address);
      //Check URI
      expect(await avatarContract.tokenURI(3)).to.equal(test_uri);
    });

    it("Should Post as Owned-Soul", async function () {
      let testerToken = await avatarContract.tokenByAddress(this.testerAddr);
      let post = {
        tokenId: testerToken,
        uri:test_uri,
      };

      //Validate Permissions
      await expect(
        //Failed Post
        avatarContract.connect(tester4).post(post.tokenId, post.uri)
      ).to.be.revertedWith("SOUL:NOT_YOURS");

      //Successful Post
      let tx = await avatarContract.connect(tester).post(post.tokenId, post.uri);
      await tx.wait();  //wait until the transaction is mined
      //Expect Event
      await expect(tx).to.emit(avatarContract, 'Post').withArgs(this.testerAddr, post.tokenId, post.uri);
    });

    it("Should Post as a Lost-Soul", async function () {
      let post = {
        tokenId: unOwnedTokenId,
        uri: test_uri,
      };

      //Validate Permissions
      await expect(
        //Failed Post
        avatarContract.connect(tester4).post(post.tokenId, post.uri)
      ).to.be.revertedWith("SOUL:NOT_YOURS");

      //Successful Post
      let tx = await avatarContract.post(post.tokenId, post.uri);
      await tx.wait();  //wait until the transaction is mined
      //Expect Event
      await expect(tx).to.emit(avatarContract, 'Post').withArgs(this.ownerAddr, post.tokenId, post.uri);
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

    it("Should protect from unauthorized reputation changes", async function () {
      //Rep Call Data      
      let repCall = { tokenId:1, domain:"personal", rating:1, amount:2};
      //Should Fail - Require Permissions
      await expect(
        avatarContract.repAdd(repCall.tokenId, repCall.domain, repCall.rating, repCall.amount)
      ).to.be.revertedWith("UNAUTHORIZED_ACCESS");
    });

  }); //Soul

  /**
   * Game Contract
   */
  describe("Game", function () {
    
    before(async function () {
      //Mint Avatars for Participants
      await avatarContract.connect(owner).mint(test_uri);
      await avatarContract.connect(admin).mint(test_uri);
      // await avatarContract.connect(tester3).mint(test_uri);
      await avatarContract.connect(tester4).mint(test_uri);
      await avatarContract.connect(tester5).mint(test_uri);
      await avatarContract.connect(authority).mint(test_uri);

      //Simulate to Get New Game Address
      let JAddr = await hubContract.callStatic.gameMake("Test Game", test_uri);
      // let JAddr = await hubContract.connect(admin).callStatic.gameMake("Test Game", test_uri);

      //Create New Game
      // let tx = await hubContract.connect(admin).gameMake("Test Game", test_uri);
      let tx = await hubContract.gameMake("Test Game", test_uri);
      //Expect Valid Address
      expect(JAddr).to.be.properAddress;
      //Expect Incident Created Event
      await expect(tx).to.emit(hubContract, 'ContractCreated').withArgs("game", JAddr);
      //Init Game Contract Object
      gameContract = await ethers.getContractFactory("GameUpgradable").then(res => res.attach(JAddr));
      this.gameContract = gameContract;
    });

    it("Should Update Contract URI", async function () {
      //Before
      expect(await this.gameContract.contractURI()).to.equal(test_uri);
      //Change
      await this.gameContract.setContractURI(test_uri2);
      //After
      expect(await this.gameContract.contractURI()).to.equal(test_uri2);
    });

    it("Users can join as a member", async function () {
      //Check Before
      expect(await this.gameContract.roleHas(this.testerAddr, "member")).to.equal(false);
      //Join Game
      await this.gameContract.connect(tester).join();
      //Check After
      expect(await this.gameContract.roleHas(this.testerAddr, "member")).to.equal(true);
    });

    it("Role Should Track Avatar Owner", async function () {
      //Check Before
      expect(await this.gameContract.roleHas(this.tester5Addr, "member")).to.equal(false);
      // expect(await this.gameContract.roleHas(this.tester5Addr, "member")).to.equal(false);
      //Join Game
      await this.gameContract.connect(tester5).join();
      //Check
      expect(await this.gameContract.roleHas(this.tester5Addr, "member")).to.equal(true);
      //Get Tester5's Avatar TokenID
      let tokenId = await avatarContract.tokenByAddress(this.tester5Addr);
      // console.log("Tester5 Avatar Token ID: ", tokenId);
      //Move Avatar Token to Tester3
      let tx = await avatarContract.transferFrom(this.tester5Addr, this.tester3Addr, tokenId);
      await tx.wait();
      await expect(tx).to.emit(avatarContract, 'Transfer').withArgs(this.tester5Addr, this.tester3Addr, tokenId);
      //Expect Change of Ownership
      expect(await avatarContract.ownerOf(tokenId)).to.equal(this.tester3Addr);
      //Check Membership
      expect(await this.gameContract.roleHas(this.tester3Addr, "member")).to.equal(true);
      // expect(await this.gameContract.roleHas(this.tester5Addr, "member")).to.equal(false);
      //Should Fail - No Avatar For Contract
      await expect(
        this.gameContract.roleHas(this.tester5Addr, "member")
      ).to.be.revertedWith("ERC1155Tracker: requested account not found on source contract");
    });

    it("Users can leave", async function () {
      //Check Before
      expect(await this.gameContract.roleHas(this.testerAddr, "member")).to.equal(true);
      //Join Game
      await this.gameContract.connect(tester).leave();
      //Check After
      expect(await this.gameContract.roleHas(this.testerAddr, "member")).to.equal(false);
    });

    it("Owner can appoint Admin", async function () {
      //Check Before
      expect(await this.gameContract.roleHas(this.adminAddr, "admin")).to.equal(false);
      //Should Fail - Require Permissions
      await expect(
        this.gameContract.connect(tester).roleAssign(this.adminAddr, "admin")
      ).to.be.revertedWith("INVALID_PERMISSIONS");
      //Assign Admin
      await this.gameContract.roleAssign(this.adminAddr, "admin");
      //Check After
      expect(await this.gameContract.roleHas(this.adminAddr, "admin")).to.equal(true);
    });

    it("Admin can appoint authority", async function () {
      //Check Before
      expect(await this.gameContract.roleHas(this.authorityAddr, "authority")).to.equal(false);
      //Should Fail - Require Permissions
      await expect(
        this.gameContract.connect(tester2).roleAssign(this.authorityAddr, "authority")
      ).to.be.revertedWith("INVALID_PERMISSIONS");
      //Assign Authority
      await this.gameContract.connect(admin).roleAssign(this.authorityAddr, "authority");
      //Check After
      expect(await this.gameContract.roleHas(this.authorityAddr, "authority")).to.equal(true);
    });

    it("Admin can Assign Roles to Lost-Souls", async function () {
      //Check Before
      expect(await this.gameContract.roleHasByToken(unOwnedTokenId, "authority")).to.equal(false);
      //Assign Authority
      await this.gameContract.connect(admin).roleAssignToToken(unOwnedTokenId, "authority")
      //Check After
      expect(await this.gameContract.roleHasByToken(unOwnedTokenId, "authority")).to.equal(true);
    });

    it("Can change Roles (Promote / Demote)", async function () {
      //Check Before
      expect(await this.gameContract.roleHas(this.tester4Addr, "admin")).to.equal(false);
      //Join Game
      let tx = await this.gameContract.connect(tester4).join();
      await tx.wait();
      //Check Before
      expect(await this.gameContract.roleHas(this.tester4Addr, "member")).to.equal(true);
      //Upgrade to Admin
      await this.gameContract.roleChange(this.tester4Addr, "member", "admin");
      //Check After
      expect(await this.gameContract.roleHas(this.tester4Addr, "admin")).to.equal(true);
    });
    
    it("Should store Rules", async function () {
      // let actionGUID = '0xa7440c99ff5cd38fc9e0bff1d6dbf583cc757a83a3424bdc4f5fd6021a2e90e2';//await actionContract.callStatic.actionAdd(action);
      let confirmation = {
        ruling: "authority",  //Decision Maker
        evidence: true, //Require Evidence
        witness: 1,  //Minimal number of witnesses
      };
      let rule = {
        // uint256 about;    //About What (Token URI +? Contract Address)
        about: actionGUID, //"0xa7440c99ff5cd38fc9e0bff1d6dbf583cc757a83a3424bdc4f5fd6021a2e90e2",
        affected: "investor",  //Beneficiary
        // string uri;     //Text, Conditions & additional data
        uri: "ADDITIONAL_DATA_URI",
        // bool negation;  //false - Commision  true - Omission
        negation: false,
      };
      // Effect Object (Describes Changes to Rating By Type)
      let effects1 = [
        {name:'professional', value:5, direction:false},
        {name:'social', value:5, direction:true},
      ];
      let rule2 = {
        // uint256 about;    //About What (Token URI +? Contract Address)
        about: actionGUID, //"0xa7440c99ff5cd38fc9e0bff1d6dbf583cc757a83a3424bdc4f5fd6021a2e90e2",
        affected: "god",  //Beneficiary
        // string uri;     //Text, Conditions & additional data
        uri: "ADDITIONAL_DATA_URI",
        // bool negation;  //false - Commision  true - Omission
        negation: false,
      };
      // Effect Object (Describes Changes to Rating By Type)
      let  effects2 = [
        {name:'environmental', value:10, direction:false},
        {name:'personal', value:4, direction:true},
      ];
     
      //Add Rule
      let tx = await gameContract.connect(admin).ruleAdd(rule, confirmation, effects1);
      // const gameRules = await ethers.getContractAt("IRules", this.gameContract.address);
      // let tx = await gameRules.connect(admin).ruleAdd(rule, confirmation, effects1);
      
      // wait until the transaction is mined
      await tx.wait();
      // const receipt = await tx.wait()
      // console.log("Rule Added", receipt.logs);
      // console.log("Rule Added Events: ", receipt.events);

      //Expect Event
      await expect(tx).to.emit(this.ruleRepo, 'Rule').withArgs(1, rule.about, rule.affected, rule.uri, rule.negation);
      
      // await expect(tx).to.emit(this.ruleRepo, 'RuleEffects').withArgs(1, rule.effects.environmental, rule.effects.personal, rule.effects.social, rule.effects.professional);
      for(let effect of effects1){
        await expect(tx).to.emit(this.ruleRepo, 'RuleEffect').withArgs(1, effect.direction, effect.value, effect.name);
      }
      await expect(tx).to.emit(this.ruleRepo, 'Confirmation').withArgs(1, confirmation.ruling, confirmation.evidence, confirmation.witness);

      //Add Another Rule
      let tx2 = await gameContract.connect(admin).ruleAdd(rule2, confirmation, effects2);
      
            
      //Expect Event
      await expect(tx2).to.emit(this.ruleRepo, 'Rule').withArgs(2, rule2.about, rule2.affected, rule2.uri, rule2.negation);
      // await expect(tx2).to.emit(this.ruleRepo, 'RuleEffects').withArgs(2, rule2.effects.environmental, rule2.effects.personal, rule2.effects.social, rule2.effects.professional);
      await expect(tx2).to.emit(this.ruleRepo, 'Confirmation').withArgs(2, confirmation.ruling, confirmation.evidence, confirmation.witness);

      // expect(await gameContract.ruleAdd(actionContract.address)).to.equal("Hello, world!");
      // let ruleData = await gameContract.ruleGet(1);
      
      // console.log("Rule Getter:", typeof ruleData, ruleData);   //some kind of object array crossbread
      // console.log("Rule Getter Effs:", ruleData.effects);  //V
      // console.log("Rule Getter:", JSON.stringify(ruleData)); //As array. No Keys
      
      // await expect(ruleData).to.include.members(Object.values(rule));
    });

    it("Should Update Rule", async function () {
      let actionGUID = '0xa7440c99ff5cd38fc9e0bff1d6dbf583cc757a83a3424bdc4f5fd6021a2e90e2';
      let rule = {
        about: actionGUID, //"0xa7440c99ff5cd38fc9e0bff1d6dbf583cc757a83a3424bdc4f5fd6021a2e90e2",
        affected: "god",  //Beneficiary
        uri: "ADDITIONAL_DATA_URI",
        negation: false,
      };
      let  effects = [
        {name:'environmental', value:1, direction:false},
        {name:'personal', value:1, direction:true},
      ];
      let tx = await gameContract.connect(admin).ruleUpdate(2, rule, effects);

      // let curEffects = await gameContract.effectsGet(2);
      // console.log("Effects", curEffects);
      // expect(curEffects).to.include.members(Object.values(effects));    //Doesn't Work...

    });

    it("Should Write a Post", async function () {
      let testerToken = await avatarContract.tokenByAddress(this.testerAddr);
      let post = {
        entRole:"member",
        tokenId: testerToken,
        uri:test_uri,
      };

      //Join Game
      let tx1 = await this.gameContract.connect(tester).join();
      await tx1.wait();
      //Make Sure Account Has Role
      expect(await this.gameContract.roleHas(this.testerAddr, "member")).to.equal(true);

      //Validate Permissions
      await expect(
        //Failed Post
        this.gameContract.connect(tester4).post(post.entRole, post.tokenId, post.uri)
      ).to.be.revertedWith("SOUL:NOT_YOURS");

      //Successful Post
      let tx2 = await this.gameContract.connect(tester).post(post.entRole, post.tokenId, post.uri);
      await tx2.wait();  //wait until the transaction is mined
      //Expect Event
      await expect(tx2).to.emit(this.gameContract, 'Post').withArgs(this.testerAddr, post.tokenId, post.entRole, post.uri);
    });
    
    it("Should Update Membership Token URI", async function () {
      //Protected
      await expect(
        gameContract.connect(tester3).setRoleURI("admin", test_uri)
      ).to.be.revertedWith("INVALID_PERMISSIONS");
      //Set Admin Token URI
      await gameContract.connect(admin).setRoleURI("admin", test_uri);
      //Validate
      expect(await gameContract.roleURI("admin")).to.equal(test_uri);
    });

    describe("Closed Game", function () {

      it("Can Close Game", async function () {
        //Change to Closed Game
        let tx = await this.gameContract.connect(admin).confSet("isClosed", "true");
        //Expect Incident Created Event
        await expect(tx).to.emit(this.openRepo, 'StringSet').withArgs(this.gameContract.address, "isClosed", "true");
        //Validate
        expect(await this.gameContract.confGet("isClosed")).to.equal("true");
      });

      it("Should Fail to Join Game", async function () {
        //Validate Permissions
        await expect(
          gameContract.connect(tester4).join()
        ).to.be.revertedWith("CLOSED_SPACE");
      });
      
      it("Can Apply to Join", async function () {
        //Get Tester's Avatar TokenID
        let tokenId = await avatarContract.tokenByAddress(this.testerAddr);
        //Apply to Join Game
        let tx = await this.gameContract.connect(tester).nominate(tokenId, test_uri);
        await tx.wait();
        //Expect Event
        await expect(tx).to.emit(gameContract, 'Nominate').withArgs(this.testerAddr, tokenId, test_uri);
      });

      it("Can Re-Open Game", async function () {
        //Change to Closed Game
        await this.gameContract.connect(admin).confSet("isClosed", "false");
        //Validate
        expect(await this.gameContract.confGet("isClosed")).to.equal("false");
      });
      
    });

    describe("Game Extensions", function () {

      it("Should Set DAO Extension Contract", async function () {
        //Deploy Extensions
        let dummyContract1 = await ethers.getContractFactory("Dummy").then(res => res.deploy());
        let dummyContract2 = await ethers.getContractFactory("Dummy2").then(res => res.deploy());
        //Set DAO Extension Contract
        hubContract.assocAdd("GAME_DAO", dummyContract1.address);
        hubContract.assocAdd("GAME_DAO", dummyContract2.address);
        // console.log("Setting GAME_DAO Extension: ", dummyContract1.address);
        // console.log("Setting GAME_DAO Extension: ", dummyContract2.address);
      });

      it("Should Set Game Type", async function () {
        //Change Game Type
        await this.gameContract.connect(admin).confSet("type", "DAO");
        //Validate
        expect(await this.gameContract.confGet("type")).to.equal("DAO");
      });

      it("Should Fallback to Extension Function", async function () {
        this.daoContract = await ethers.getContractFactory("Dummy2").then(res => res.attach(this.gameContract.address));
        this.daoContract2 = await ethers.getContractFactory("Dummy2").then(res => res.attach(this.gameContract.address));
        //First Dummy        
        expect(await await this.daoContract.debugFunc()).to.equal("Hello World Dummy");
        //Second Dummy
        expect(await await this.daoContract2.debugFunc2()).to.equal("Hello World Dummy 2");
        //Second Dummy Extracts Data from Main Game Contract
        expect(await await this.daoContract2.useSelf()).to.equal("Game Type: DAO");
      });

    });

  }); //Game

  /**
   * Incident Contract
   */
  describe("Incident", function () {

    it("Should be Created (by Game)", async function () {
      //Soul Tokens
      let adminToken = await avatarContract.tokenByAddress(this.adminAddr);
      let tester2Token = await avatarContract.tokenByAddress(this.tester2Addr);
    
      let incidentName = "Test Incident #1";
      let ruleRefArr = [
        {
          game: gameContract.address, 
          ruleId: 1,
        }
      ];
      let roleRefArr = [
        {
          role: "subject",
          tokenId: tester2Token,
        },
        {
          role: "affected",
          tokenId: unOwnedTokenId,
        },
      ];
      let posts = [
        {
          tokenId: adminToken, 
          entRole: "admin",
          uri: test_uri,
        }
      ];

      //Join Game (as member)
      await gameContract.connect(admin).join();
      //Assign Admin as Member
      // await this.gameContract.roleAssign(this.adminAddr, "member");

      //Simulate - Get New Incident Address
      let incidentAddr = await gameContract.connect(admin).callStatic.incidentMake(incidentName, test_uri, ruleRefArr, roleRefArr, posts);
      // console.log("New Incident Address: ", incidentAddr);

      //Create New Incident
      let tx = await gameContract.connect(admin).incidentMake(incidentName, test_uri, ruleRefArr, roleRefArr, posts);
      //Expect Valid Address
      expect(incidentAddr).to.be.properAddress;
      //Init Incident Contract
      this.incidentContract = await ethers.getContractFactory("IncidentUpgradable").then(res => res.attach(incidentAddr));
      //Expect Incident Created Event
      await expect(tx).to.emit(gameContract, 'IncidentCreated').withArgs(1, incidentAddr);
      //Expect Post Event
      await expect(tx).to.emit(this.incidentContract, 'Post').withArgs(this.adminAddr, posts[0].tokenId, posts[0].entRole, posts[0].uri);
    });
    
    it("Should be Created & Opened (by Game)", async function () {
      //Soul Tokens
      let adminToken = await avatarContract.tokenByAddress(this.adminAddr);
      let tester2Token = await avatarContract.tokenByAddress(this.tester2Addr);
      let tester3Token = await avatarContract.tokenByAddress(this.tester3Addr);

      let incidentName = "Test Incident #1";
      let ruleRefArr = [
        {
          game: gameContract.address, 
          ruleId: 1,
        }
      ];
      let roleRefArr = [
        {
          role: "subject",
          tokenId: tester2Token,
        },
        {
          role: "witness",
          tokenId: tester3Token,
        }
      ];
      let posts = [
        {
          tokenId: adminToken, 
          entRole: "admin",
          uri: test_uri,
        }
      ];
      //Simulate - Get New Incident Address
      let incidentAddr = await gameContract.connect(admin).callStatic.incidentMake(incidentName, test_uri, ruleRefArr, roleRefArr, posts);
      //Create New Incident
      let tx = await gameContract.connect(admin).incidentMakeOpen(incidentName, test_uri, ruleRefArr, roleRefArr, posts);
      //Expect Valid Address
      expect(incidentAddr).to.be.properAddress;
      //Init Incident Contract
      let incidentContract = await ethers.getContractFactory("IncidentUpgradable").then(res => res.attach(incidentAddr));
      //Expect Incident Created Event
      await expect(tx).to.emit(gameContract, 'IncidentCreated').withArgs(2, incidentAddr);
      //Expect Post Event
      // await expect(tx).to.emit(incidentContract, 'Post').withArgs(this.adminAddr, posts[0].tokenId, posts[0].entRole, posts[0].postRole, posts[0].uri);
      await expect(tx).to.emit(incidentContract, 'Post').withArgs(this.adminAddr, posts[0].tokenId, posts[0].entRole, posts[0].uri);
    });

    it("Should Update Incident Contract URI", async function () {
      //Before
      expect(await this.incidentContract.contractURI()).to.equal(test_uri);
      //Change
      await this.incidentContract.setContractURI(test_uri2);
      //After
      expect(await this.incidentContract.contractURI()).to.equal(test_uri2);
    });

    it("Should Auto-Appoint creator as Admin", async function () {
      expect(
        await this.incidentContract.roleHas(this.adminAddr, "admin")
      ).to.equal(true);
    });

    it("Tester expected to be in the subject role", async function () {
      expect(
        await this.incidentContract.roleHas(this.tester2Addr, "subject")
      ).to.equal(true);
    });

    it("Users Can Apply to Join", async function () {
      //Get Tester's Avatar TokenID
      let tokenId = await avatarContract.tokenByAddress(this.testerAddr);
      //Apply to Join Game
      let tx = await this.incidentContract.connect(tester).nominate(tokenId, test_uri);
      await tx.wait();
      //Expect Event
      await expect(tx).to.emit(this.incidentContract, 'Nominate').withArgs(this.testerAddr, tokenId, test_uri);
    });

    it("Should Update", async function () {
      let testIncidentContract = await ethers.getContractFactory("IncidentUpgradable").then(res => res.deploy());
      await testIncidentContract.deployed();
      //Update Incident Beacon (to the same implementation)
      hubContract.upgradeIncidentImplementation(testIncidentContract.address);
    });

    it("Should Add Rules", async function () {
      let ruleRef = {
        game: gameContract.address, 
        id: 2, 
        // affected: "investor",
      };
      // await this.incidentContract.ruleAdd(ruleRef.game,  ruleRef.id, ruleRef.affected);
      await this.incidentContract.connect(admin).ruleAdd(ruleRef.game,  ruleRef.id);
    });
    
    it("Should Write a Post", async function () {
      let tester2Token = await avatarContract.tokenByAddress(this.tester2Addr);
      let post = {
        tokenId: tester2Token,
        entRole:"subject",
        uri:test_uri,
      };

      //Validate Permissions
      await expect(
        //Failed Post
        this.incidentContract.connect(tester).post(post.entRole, post.tokenId, post.uri)
      ).to.be.revertedWith("SOUL:NOT_YOURS");

      //Successful Post
      let tx = await this.incidentContract.connect(tester2).post(post.entRole, post.tokenId, post.uri);
      // wait until the transaction is mined
      await tx.wait();
      //Expect Event
      await expect(tx).to.emit(this.incidentContract, 'Post').withArgs(this.tester2Addr, post.tokenId, post.entRole, post.uri);
    });

    it("Should Update Token URI", async function () {
      //Protected
      await expect(
        this.incidentContract.connect(tester3).setRoleURI("admin", test_uri)
      ).to.be.revertedWith("INVALID_PERMISSIONS");
      //Set Admin Token URI
      await this.incidentContract.connect(admin).setRoleURI("admin", test_uri);
      //Validate
      expect(await this.incidentContract.roleURI("admin")).to.equal(test_uri);
    });

    it("Should Assign Witness", async function () {
      //Assign Admin
      await this.incidentContract.connect(admin).roleAssign(this.tester3Addr, "witness");
      //Validate
      expect(await this.incidentContract.roleHas(this.tester3Addr, "witness")).to.equal(true);
    });

    it("Game Authoritys Can Assign Themselves to Incident", async function () {
      //Assign as Game Authority
      gameContract.connect(admin).roleAssign(this.tester4Addr, "authority")
      //Assign Incident Authority
      await this.incidentContract.connect(tester4).roleAssign(this.tester4Addr, "authority");
      //Validate
      expect(await this.incidentContract.roleHas(this.tester4Addr, "authority")).to.equal(true);
    });

    it("User Can Open Incident", async function () {
      //Validate
      await expect(
        this.incidentContract.connect(tester2).stageFile()
      ).to.be.revertedWith("ROLE:CREATOR_OR_ADMIN");
      //File Incident
      let tx = await this.incidentContract.connect(admin).stageFile();
      //Expect State Event
      await expect(tx).to.emit(this.incidentContract, 'Stage').withArgs(1);
    });

    it("Should Validate Authority with parent game", async function () {
      //Validate
      await expect(
        this.incidentContract.connect(admin).roleAssign(this.tester3Addr, "authority")
      ).to.be.revertedWith("User Required to hold same role in the Game context");
    });

    it("Anyone Can Apply to Join", async function () {
      //Get Tester's Avatar TokenID
      let tokenId = await avatarContract.tokenByAddress(this.testerAddr);
      //Apply to Join Game
      let tx = await this.incidentContract.connect(tester).nominate(tokenId, test_uri);
      await tx.wait();
      //Expect Event
      await expect(tx).to.emit(this.incidentContract, 'Nominate').withArgs(this.testerAddr, tokenId, test_uri);
    });

    it("Should Accept a Authority From the parent game", async function () {
      //Check Before
      // expect(await this.gameContract.roleHas(this.testerAddr, "authority")).to.equal(true);
      //Assign Authority
      await this.incidentContract.connect(admin).roleAssign(this.authorityAddr, "authority");
      //Check After
      expect(await this.incidentContract.roleHas(this.authorityAddr, "authority")).to.equal(true);
    });
    
    it("Should Wait for Verdict Stage", async function () {
      //File Incident
      let tx = await this.incidentContract.connect(authority).stageWaitForVerdict();
      //Expect State Event
      await expect(tx).to.emit(this.incidentContract, 'Stage').withArgs(2);
    });

    it("Should Wait for authority", async function () {
      let verdict = [{ ruleId:1, decision: true }];
      //File Incident -- Expect Failure
      await expect(
        this.incidentContract.connect(tester2).stageVerdict(verdict, test_uri)
      ).to.be.revertedWith("ROLE:AUTHORITY_ONLY");
    });

    it("Should Accept Verdict URI & Close Incident", async function () {
      let verdict = [{ruleId:1, decision:true}];
      //Submit Verdict & Close Incident
      let tx = await this.incidentContract.connect(authority).stageVerdict(verdict, test_uri);
      //Expect Verdict Event
      await expect(tx).to.emit(this.incidentContract, 'Verdict').withArgs(test_uri, this.authorityAddr);
      //Expect State Event
      await expect(tx).to.emit(this.incidentContract, 'Stage').withArgs(6);
    });

    // it("[TODO] Can Change Rating", async function () {

      //TODO: Tests for Collect Rating
      // let repCall = { tokenId:?, domain:?, rating:?};
      // let result = this.gameContract.getRepForDomain(avatarContract.address,repCall. tokenId, repCall.domain, repCall.rating);

      // //Expect Event
      // await expect(tx).to.emit(avatarContract, 'ReputationChange').withArgs(repCall.tokenId, repCall.domain, repCall.rating, repCall.amount);

      //Validate State
      // getRepForDomain(address contractAddr, uint256 tokenId, string domain, bool rating) public view override returns (uint256){

      // let rep = await avatarContract.getRepForDomain(repCall.tokenId, repCall.domain, repCall.rating);
      // expect(rep).to.equal(repCall.amount);

      // //Other Domain Rep - Should be 0
      // expect(await avatarContract.getRepForDomain(repCall.tokenId, repCall.domain + 1, repCall.rating)).to.equal(0);

    // });

  }); //Incident
    
});
