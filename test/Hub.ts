import { expect } from "chai";
import { Contract, ContractReceipt, Signer } from "ethers";
import { ethers } from "hardhat";

//Test Data
const ZERO_ADDR = '0x0000000000000000000000000000000000000000';
let test_uri = "ipfs://QmQxkoWcpFgMa7bCzxaANWtSt43J1iMgksjNnT4vM1Apd7"; //"TEST_URI";


describe("Hub", function () {
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

        //Deploy Config
        const ConfigContract = await ethers.getContractFactory("Config");
        configContract1 = await ConfigContract.connect(account1).deploy();
        configContract2 = await ConfigContract.connect(account2).deploy();

        //Deploy Case Implementation
        this.caseContract = await ethers.getContractFactory("Case").then(res => res.deploy());
        //Jurisdiction Upgradable Implementation
        this.jurisdictionUpContract = await ethers.getContractFactory("JurisdictionUpgradable").then(res => res.deploy());

        //Deploy Hub
        hubContract = await ethers.getContractFactory("Hub").then(res => res.deploy(configContract1.address, this.jurisdictionUpContract.address, this.caseContract.address));
        //Deploy Hub
        hubContract2 = await ethers.getContractFactory("Hub").then(res => res.deploy(configContract2.address, this.jurisdictionUpContract.address, this.caseContract.address));

        //Deploy Avatar
        avatarContract = await ethers.getContractFactory("AvatarNFT").then(res => res.deploy(hubContract.address));
        //Set Avatar Contract to Hub
        hubContract.setAssoc("avatar", avatarContract.address);

        //Deploy History
        actionContract = await ethers.getContractFactory("ActionRepo").then(res => res.deploy(hubContract.address));
        //Set Avatar Contract to Hub
        hubContract.setAssoc("history", actionContract.address);
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