import { expect } from "chai";
import { Contract, ContractReceipt, Signer } from "ethers";
import { ethers } from "hardhat";
const {  upgrades } = require("hardhat");


//Test Data
// const ZERO_ADDR = '0x0000000000000000000000000000000000000000';
// let test_uri = "ipfs://QmQxkoWcpFgMa7bCzxaANWtSt43J1iMgksjNnT4vM1Apd7"; //"TEST_URI";

describe("Deployment", function () {
    let jurisdictionContract: Contract;
    let caseContract: Contract;
    let hubContract: Contract;
    let configContract: Contract;
    let actionRepoContract: Contract;
    let assocRepoContract: Contract;
    let openRepoContract: Contract;
    let SoulUpgradable: Contract;
    // let actionContract: Contract;
    let oldHubContract: Contract;

    //Addresses
    let account1: Signer;
    let account2: Signer;

    before(async function () {

        //Populate Accounts
        [account1, account2] = await ethers.getSigners();

        //--- AssocRepo
        // assocRepoContract = await ethers.getContractFactory("AssocRepo").then(res => res.deploy());
        // await assocRepoContract.deployed();
       
        //--- OpenRepo (UUDP)
        openRepoContract = await ethers.getContractFactory("OpenRepoUpgradable")
            .then(Contract => upgrades.deployProxy(Contract, [],{kind: "uups", timeout: 120000}));

        //--- Config
        configContract = await ethers.getContractFactory("Config").then(res => res.deploy());
        await configContract.deployed();

        //--- Jurisdiction Implementation
        jurisdictionContract = await ethers.getContractFactory("JurisdictionUpgradable").then(res => res.deploy());
        await jurisdictionContract.deployed();

        //--- Case Implementation
        caseContract = await ethers.getContractFactory("CaseUpgradable").then(res => res.deploy());
        await caseContract.deployed();
        
    });

    it("Should Deploy Upgradable Hub Contract", async function () {
        //Deploy Avatar Upgradable
        const HubUpgradable = await ethers.getContractFactory("HubUpgradable");
        // deploying new proxy
        const proxyHub = await upgrades.deployProxy(HubUpgradable,
            [
                // assocRepoContract.address, 
                openRepoContract.address,
                configContract.address, 
                jurisdictionContract.address,
                caseContract.address,
            ],{
            // https://docs.openzeppelin.com/upgrades-plugins/1.x/api-hardhat-upgrades#common-options
            kind: "uups",
            timeout: 120000
        });
        await proxyHub.deployed();
        // console.log("HubUpgradable deployed to:", proxyHub.address);
        hubContract = proxyHub;
    });

    it("Should Remember & Serve Config", async function () {
        expect(await hubContract.getAssoc("config")).to.equal(configContract.address);
    });

    it("Should Change Hub", async function () {
       //--- Hub Contract
       //Deploy Hub Upgradable
       const HubUpgradable = await ethers.getContractFactory("HubUpgradable");
       const proxyHub2 = await upgrades.deployProxy(HubUpgradable,
           [
               // assocRepoContract.address, 
               openRepoContract.address,
               configContract.address, 
               jurisdictionContract.address,
               caseContract.address,
           ],{
           // https://docs.openzeppelin.com/upgrades-plugins/1.x/api-hardhat-upgrades#common-options
           kind: "uups",
           timeout: 120000
       });
       await proxyHub2.deployed();
       
        // console.log("Hub Address:", hubContract.address);
    
        proxyHub2.hubChange(hubContract.address);
    });

    it("Should Deploy Upgradable Soul Contract", async function () {
        //Deploy Avatar Upgradable
        const SoulUpgradable = await ethers.getContractFactory("SoulUpgradable");
        // deploying new proxy
        const proxyAvatar = await upgrades.deployProxy(SoulUpgradable,
            [hubContract.address],{
            // https://docs.openzeppelin.com/upgrades-plugins/1.x/api-hardhat-upgrades#common-options
            kind: "uups",
            timeout: 120000
        });
        await proxyAvatar.deployed();
        this.avatarContract = proxyAvatar;
        //Set Avatar Contract to Hub
        hubContract.setAssoc("avatar", proxyAvatar.address);
        // console.log("SoulUpgradable deployed to:", proxyAvatar.address);
    });

    it("Should Add Avatar", async function () {
        await this.avatarContract.add("");
    });

    it("Should Deploy History (ActionRepo)", async function () {
        /*
        //--- ActionRepo
        actionRepoContract = await ethers.getContractFactory("ActionRepo").then(res => res.deploy(hubContract.address));
        //Set Action Repo Contract to Hub
        hubContract.setAssoc("history", actionRepoContract.address);
        */

        //Deploy Avatar Upgradable
        const ActionRepo = await ethers.getContractFactory("ActionRepoTrackerUp");
        // deploying new proxy
        const proxyActionRepo = await upgrades.deployProxy(ActionRepo,
            [hubContract.address],{
            // https://docs.openzeppelin.com/upgrades-plugins/1.x/api-hardhat-upgrades#common-options
            kind: "uups",
            timeout: 120000
        });
        await proxyActionRepo.deployed();
        //Set Avatar Contract to Hub
        hubContract.setAssoc("history", proxyActionRepo.address);
        // this.historyContract = proxyActionRepo;
        // console.log("ActionRepoTrackerUp deployed to:", proxyActionRepo.address);
    });



    /* COPIED
    it("Should Be Secure", async function () {
        await expect(
            hubContract.connect(account2).hubChange(hubContract2.address)
          ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should Remember & Serve Config", async function () {
        expect(await hubContract.getConfig()).to.equal(configContract.address);
    });

    it("Should Move Children Contracts to a New Hub", async function () {
        //Validate Configs
        expect(await configContract.owner()).to.equal(this.addr1);
        expect(await configContract2.owner()).to.equal(this.addr2);
        //Validate Hub        
        expect(await hubContract.owner()).to.equal(this.addr1);
        expect(await hubContract2.owner()).to.equal(this.addr2);
        //Check Before
        expect(await avatarContract.owner()).to.equal(this.addr1);
        expect(await actionContract.owner()).to.equal(this.addr1);
        //Change Hub
        hubContract.hubChange(hubContract2.address);
        //Check After
        expect(await avatarContract.owner()).to.equal(this.addr2);
        expect(await actionContract.owner()).to.equal(this.addr2);
    });
    */
        
    describe("Mock", function () {
        it("Should Deploy Mock Hub Contract", async function () {
            //--- Mock Hub
            let mockHub = await ethers.getContractFactory("HubMock").then(res => res.deploy(
                // assocRepoContract.address, 
                openRepoContract.address,
                configContract.address, 
                jurisdictionContract.address,
                caseContract.address
            ));
            await mockHub.deployed();
            // console.log("MockHub Deployed to:", mockHub.address);
        });
    });

});


