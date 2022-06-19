//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
// import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/IConfig.sol";
import "./interfaces/IAssoc.sol";
import "./public/interfaces/IOpenRepo.sol";
import "./interfaces/ICommonYJ.sol";
import "./interfaces/IHub.sol";
import "./interfaces/IJurisdictionUp.sol";
import "./interfaces/ICase.sol";
import "./interfaces/IAvatar.sol";
import "./libraries/DataTypes.sol";
import "./abstract/ContractBase.sol";
// import "./abstract/Assoc.sol";
import "./abstract/AssocExt.sol";


/**
 * YJ Hub Contract
 * - Hold Known Contract Addresses (Avatar, History)
 * - Contract Factory (Jurisdictions & Cases)
 * - Remember Products (Jurisdictions & Cases)
 */
contract HubUpgradable is 
        IHub 
        , IAssoc
        , Initializable
        , ContractBase
        , OwnableUpgradeable 
        , UUPSUpgradeable
        , AssocExt
        , ERC165Upgradeable
    {

    //---Storage
    address public beaconCase;
    address public beaconJurisdiction;  //TBD

    // mapping(string => address) internal _contracts;      // Mapping for Used Contracts

    //Avatar Contract Address
    // address public override avatarContract;
    //Action Repo
    // address public override historyContract;

    // using Counters for Counters.Counter;
    // Counters.Counter internal _tokenIds; //Track Last Token ID
    // Counters.Counter internal _caseIds;  //Track Last Case ID

    // Arbitrary contract designation signature
    string public constant override role = "YJHub";
    string public constant override symbol = "YJHub";

    //--- Storage
    // address internal _CONFIG;    //Configuration Contract
    IConfig private _CONFIG;  //Configuration Contract       //DEPRECATE

    mapping(address => bool) internal _jurisdictions; // Mapping for Active Jurisdictions   //[TBD]
    mapping(address => address) internal _cases;      // Mapping for Case Contracts  [C] => [J]


    //--- Functions
 
    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IHub).interfaceId 
            || interfaceId == type(IAssoc).interfaceId 
            || super.supportsInterface(interfaceId);
    }

    /// Initializer
    function initialize (
        address openRepo,
        address config, 
        address jurisdictionContract, 
        address caseContract
    ) public initializer {
        //Set Association Repo Address
        _setRepo(openRepo);

        //Initializers
        __UUPSUpgradeable_init();
        //Set Protocol's Config Address
        _setConfig(config);
        //Set Contract URI
        // _setContractURI(uri_);
        //Init Jurisdiction Contract Beacon
        UpgradeableBeacon _beaconJ = new UpgradeableBeacon(jurisdictionContract);
        beaconJurisdiction = address(_beaconJ);
        //Init Case Contract Beacon
        UpgradeableBeacon _beaconC = new UpgradeableBeacon(caseContract);
        beaconCase = address(_beaconC);
    }

    /// Upgrade Permissions
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override { }

    /// @dev Returns the address of the current owner.
    function owner() public view override(IHub, OwnableUpgradeable) returns (address) {
        return IConfig(getConfig()).owner();
    }

    /// Get Configurations Contract Address
    function getConfig() public view returns (address) {
        return repo().addressGet("config");
    }

    /// Expose Configurations Set for Current Owner
    function setConfig(address config) public onlyOwner {
        _setConfig(config);
    }

    /// Set Configurations Contract Address
    function _setConfig(address config) internal {
        //Validate Contract's Designation
        require(keccak256(abi.encodePacked(IConfig(config).symbol())) == keccak256(abi.encodePacked("YJConfig")), "Invalid Config Contract");
        //Set
        repo().addressSet("config", config);
    }

    /// Update Hub
    function hubChange(address newHubAddr) external override onlyOwner {
        //Avatar
        address avatarContract = repo().addressGet("avatar");
        if(avatarContract != address(0)){
            try ICommonYJ(avatarContract).setHub(newHubAddr){}  //Failure should not be fatal
            catch Error(string memory /*reason*/) {}
        }
        //History
        address actionRepo = repo().addressGet("history");
        if(actionRepo != address(0)){
            try ICommonYJ(actionRepo).setHub(newHubAddr) {}   //Failure should not be fatal
            catch Error(string memory reason) {
                console.log("Failed to update Hub for ActionRepo Contract", reason);
            }
        }
        //Emit Hub Change Event
        emit HubChanged(newHubAddr);
    }

    //-- Assoc

    /// Set Association
    function setAssoc(string memory key, address contractAddr) external onlyOwner {
        repo().addressSet(key, contractAddr);
    }

    /// Get Contract Association
    function getAssoc(string memory key) public view override returns(address) {
        //If string match "repo" return the repo address
        // if(keccak256(abi.encodePacked("repo")) == keccak256(abi.encodePacked(key))) return address(repo());
        
        //Return address from the Repo
        return repo().addressGet(key);
    }

    //Repo Address
    function repoAddr() external view override returns(address) {
        return address(repo());
    }

    //--- Factory 

    /// Make a new Jurisdiction
    function jurisdictionMake(string calldata name_, string calldata uri_) external override returns (address) {
        //Validate
        // require(beaconJurisdiction != address(0), "Jurisdiction Beacon Missing");      //Redundant
        //Deploy
        BeaconProxy newJurisdictionProxy = new BeaconProxy(
            beaconJurisdiction,
            abi.encodeWithSelector(
                IJurisdiction( payable(address(0)) ).initialize.selector,
                address(this),   //Hub
                name_,          //Name
                uri_            //Contract URI
            )
        );
        //Event
        emit ContractCreated("jurisdiction", address(newJurisdictionProxy));
        //Remember
        _jurisdictions[address(newJurisdictionProxy)] = true;
        //Return
        return address(newJurisdictionProxy);
    }

    /// Make a new Case
    function caseMake(
        string calldata name_, 
        string calldata uri_,
        DataTypes.RuleRef[] memory addRules,
        DataTypes.InputRoleToken[] memory assignRoles
    ) external override returns (address) {
        //Validate Caller Permissions (A Jurisdiction)
        require(_jurisdictions[_msgSender()], "UNAUTHORIZED: Valid Jurisdiction Only");

        //Validate
        // require(beaconCase != address(0), "Case Beacon Missing");    //Redundant

        //Deploy
        BeaconProxy newCaseProxy = new BeaconProxy(
            beaconCase,
            abi.encodeWithSelector(
                ICase( payable(address(0)) ).initialize.selector,
                address(this),   //Hub
                name_,          //Name
                uri_,
                addRules,
                assignRoles,
                _msgSender()    //Birth Parent (Container)
            )
        );
        //Event
        emit ContractCreated("case", address(newCaseProxy));
        //Remember
        _cases[address(newCaseProxy)] = _msgSender();
        //Return
        return address(newCaseProxy);
    }

    //--- Reputation

    /// Add Reputation (Positive or Negative)       /// Opinion Updated
    function repAdd(address contractAddr, uint256 tokenId, string calldata domain, bool rating, uint8 amount) public override {
        //TODO: Validate - Known Jurisdiction
        // require(_jurisdictions[_msgSender()], "NOT A VALID JURISDICTION");

        address avatarContract = repo().addressGet("avatar");
        //Update Avatar's Reputation    //TODO: Just Check if Contract Implements IRating
        if(avatarContract != address(0) && avatarContract == contractAddr){
            _repAddAvatar(tokenId, domain, rating, amount);
        }
    }

    /// Add Repuation to Avatar
    function _repAddAvatar(uint256 tokenId, string calldata domain, bool rating, uint8 amount) internal {
        address avatarContract = repo().addressGet("avatar");
        try IAvatar(avatarContract).repAdd(tokenId, domain, rating, amount) {}   //Failure should not be fatal
        catch Error(string memory /*reason*/) {}
    }

    //-- Upgrades

    /// Upgrade Case Implementation
    function upgradeCaseImplementation(address newImplementation) public onlyOwner {
        //Validate Interface
        // require(IERC165(newImplementation).supportsInterface(type(ICase).interfaceId), "Implmementation Does Not Support Case Interface");  //Would Cause Problems on Interface Update. Keep disabled for now.

        //Upgrade Beacon
        UpgradeableBeacon(beaconCase).upgradeTo(newImplementation);
        //Upgrade Event
        emit UpdatedImplementation("case", newImplementation);
    }

    /// Upgrade Jurisdiction Implementation [TBD]
    function upgradeJurisdictionImplementation(address newImplementation) public onlyOwner {
        //Validate Interface
        // require(IERC165(newImplementation).supportsInterface(type(ICase).interfaceId), "Implmementation Does Not Support Case Interface");  //Would Cause Problems on Interface Update. Keep disabled for now.

        //Upgrade Beacon
        UpgradeableBeacon(beaconJurisdiction).upgradeTo(newImplementation);
        //Upgrade Event
        emit UpdatedImplementation("jurisdiction", newImplementation);
    }

}