import { expect } from "chai";
import { Contract, ContractReceipt, Signer } from "ethers";
import { ethers } from "hardhat";
const {  upgrades } = require("hardhat");

//Test Data
const ZERO_ADDR = '0x0000000000000000000000000000000000000000';
let test_uri = "ipfs://QmQxkoWcpFgMa7bCzxaANWtSt43J1iMgksjNnT4vM1Apd7"; //"TEST_URI";


describe("Hub", function () {
    let openRepoContract: Contract;
    let hubContract: Contract;
    let hubContract2: Contract;
    let avatarContract: Contract;
    let actionContract: Contract;
    let configContract1: Contract;
    let configContract2: Contract;
    
    //Addresses
    let account1: Signer;
    let account2: Signer;

    before(async function () {

        //Populate Accounts
        [account1, account2] = await ethers.getSigners();

        //Extract Addresses
        this.addr1 = await account1.getAddress();
        this.addr2 = await account2.getAddress();

        //Deploy OpenRepo (UUDP)
        openRepoContract = await ethers.getContractFactory("OpenRepoUpgradable")
            .then(Contract => upgrades.deployProxy(Contract, [],{kind: "uups", timeout: 120000}));

        //Deploy Config
        const ConfigContract = await ethers.getContractFactory("Config");
        configContract1 = await ConfigContract.connect(account1).deploy();
        configContract2 = await ConfigContract.connect(account2).deploy();

        //Deploy Case Implementation
        this.caseContract = await ethers.getContractFactory("CaseUpgradable").then(res => res.deploy());
        //Game Upgradable Implementation
        this.gameUpContract = await ethers.getContractFactory("GameUpgradable").then(res => res.deploy());

        //--- Deploy Hub Upgradable
        const HubUpgradable = await ethers.getContractFactory("HubUpgradable");
        hubContract = await upgrades.deployProxy(HubUpgradable,
            [
                openRepoContract.address,
                configContract1.address,
                this.gameUpContract.address,
                this.caseContract.address
            ],{
            // https://docs.openzeppelin.com/upgrades-plugins/1.x/api-hardhat-upgrades#common-options
            kind: "uups",
            timeout: 120000
        });
        await hubContract.deployed();

        //Deploy Another Hub
        // hubContract2 = await ethers.getContractFactory("Hub").then(res => res.deploy(configContract2.address, this.gameUpContract.address, this.caseContract.address));
        hubContract2 = await upgrades.deployProxy(HubUpgradable,
            [
                openRepoContract.address,
                configContract2.address,
                this.gameUpContract.address,
                this.caseContract.address
            ],{
            // https://docs.openzeppelin.com/upgrades-plugins/1.x/api-hardhat-upgrades#common-options
            kind: "uups",
            timeout: 120000
        });
        await hubContract2.deployed();

        //Deploy Avatar
        avatarContract = await ethers.getContractFactory("SoulUpgradable").then(Contract => 
            upgrades.deployProxy(Contract,
              [hubContract.address],{
              kind: "uups",
              timeout: 120000
            })
          );

        //Set Avatar Contract to Hub
        hubContract.setAssoc("avatar", avatarContract.address);
        hubContract2.setAssoc("avatar", avatarContract.address);

        //Deploy History
        // actionContract = await ethers.getContractFactory("ActionRepo").then(res => res.deploy(hubContract.address));
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
        hubContract2.setAssoc("history", actionContract.address);
    });

    it("Should Be Secure", async function () {
        await expect(
            hubContract.connect(account2).hubChange(hubContract2.address)
          ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should Remember & Serve Config", async function () {
        expect(await hubContract.getConfig()).to.equal(configContract1.address);
    });

    it("Should Move Children Contracts to a New Hub", async function () {
        //Validate Configs
        expect(await configContract1.owner()).to.equal(this.addr1);
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

});