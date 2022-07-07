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
// import "./interfaces/IAssoc.sol";
import "./public/interfaces/IOpenRepo.sol";
import "./interfaces/ICommonYJ.sol";
import "./interfaces/IHub.sol";
import "./interfaces/IGameUp.sol";
import "./interfaces/IIncident.sol";
import "./interfaces/ISoul.sol";
import "./libraries/DataTypes.sol";
import "./abstract/ContractBase.sol";
// import "./abstract/Assoc.sol";
import "./abstract/AssocExt.sol";


/**
 * YJ Hub Contract
 * - Hold Known Contract Addresses (Avatar, History)
 * - Contract Factory (Games & Incidents)
 * - Remember Products (Games & Incidents)
 */
contract HubUpgradable is 
        IHub 
        // , IAssoc
        , Initializable
        , ContractBase
        , OwnableUpgradeable 
        , UUPSUpgradeable
        , AssocExt
        , ERC165Upgradeable
    {

    //---Storage
    address public beaconIncident;
    address public beaconGame;  //TBD

    // mapping(string => address) internal _contracts;      // Mapping for Used Contracts

    //Avatar Contract Address
    // address public override avatarContract;
    //Action Repo
    // address public override historyContract;

    // using Counters for Counters.Counter;
    // Counters.Counter internal _tokenIds; //Track Last Token ID
    // Counters.Counter internal _incidentIds;  //Track Last Incident ID

    // Arbitrary contract designation signature
    string public constant override role = "YJHub";
    string public constant override symbol = "YJHub";

    //--- Storage
    // address internal _CONFIG;    //Configuration Contract
    IConfig private _CONFIG;  //Configuration Contract       //DEPRECATE

    mapping(address => bool) internal _games; // Mapping for Active Games   //[TBD]
    mapping(address => address) internal _incidents;      // Mapping for Incident Contracts  [C] => [J]


    //--- Functions
 
    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IHub).interfaceId 
            // || interfaceId == type(IAssoc).interfaceId 
            || super.supportsInterface(interfaceId);
    }

    /// Initializer
    function initialize (
        address openRepo,
        address config, 
        address gameContract, 
        address incidentContract
    ) public initializer {
        //Set Data Repo Address
        _setRepo(openRepo);
        //Initializers
        __UUPSUpgradeable_init();
        //Set Protocol's Config Address
        _setConfig(config);
        //Set Contract URI
        // _setContractURI(uri_);
        //Init Game Contract Beacon
        UpgradeableBeacon _beaconJ = new UpgradeableBeacon(gameContract);
        beaconGame = address(_beaconJ);
        //Init Incident Contract Beacon
        UpgradeableBeacon _beaconC = new UpgradeableBeacon(incidentContract);
        beaconIncident = address(_beaconC);
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

    /// Get Contract Association
    function getAssoc(string memory key) public view override returns(address) {
        //Return address from the Repo
        return repo().addressGet(key);
    }

    /// Set Association
    function setAssoc(string memory key, address contractAddr) external onlyOwner {
        repo().addressSet(key, contractAddr);
    }
    
    /// Add Association
    function assocAdd(string memory key, address contractAddr) external onlyOwner {
        repo().addressAdd(key, contractAddr);
    }

    /// Remove Association
    function assocRemove(string memory key, address contractAddr) external onlyOwner {
        repo().addressRemove(key, contractAddr);
    }

    //Repo Address
    function repoAddr() external view override returns(address) {
        return address(repo());
    }

    //--- Factory 

    /// Make a new Game
    function gameMake(string calldata name_, string calldata uri_) external override returns (address) {
        //Deploy
        BeaconProxy newGameProxy = new BeaconProxy(
            beaconGame,
            abi.encodeWithSelector(
                IGame( payable(address(0)) ).initialize.selector,
                address(this),   //Hub
                name_,          //Name
                uri_            //Contract URI
            )
        );
        //Event
        emit ContractCreated("game", address(newGameProxy));
        //Remember
        _games[address(newGameProxy)] = true;
        //Return
        return address(newGameProxy);
    }

    /// Make a new Incident
    function incidentMake(
        string calldata name_, 
        string calldata uri_,
        DataTypes.RuleRef[] memory addRules,
        DataTypes.InputRoleToken[] memory assignRoles
    ) external override returns (address) {
        //Validate Caller Permissions (A Game)
        require(_games[_msgSender()], "UNAUTHORIZED: Valid Game Only");
        //Deploy
        BeaconProxy newIncidentProxy = new BeaconProxy(
            beaconIncident,
            abi.encodeWithSelector(
                IIncident( payable(address(0)) ).initialize.selector,
                address(this),   //Hub
                name_,          //Name
                uri_,
                addRules,
                assignRoles,
                _msgSender()    //Birth Parent (Container)
            )
        );
        //Event
        emit ContractCreated("incident", address(newIncidentProxy));
        //Remember
        _incidents[address(newIncidentProxy)] = _msgSender();
        //Return
        return address(newIncidentProxy);
    }

    //--- Reputation

    /// Add Reputation (Positive or Negative)       /// Opinion Updated
    function repAdd(address contractAddr, uint256 tokenId, string calldata domain, bool rating, uint8 amount) public override {
        //Validate - Known & Active Game 
        require(_games[_msgSender()], "UNAUTHORIZED: Valid Game Only");
        //Update Avatar's Reputation    //TODO: Just Check if Contract Implements IRating
        address avatarContract = repo().addressGet("avatar");
        if(avatarContract != address(0) && avatarContract == contractAddr){
            _repAddAvatar(tokenId, domain, rating, amount);
        }
    }

    /// Add Repuation to Avatar
    function _repAddAvatar(uint256 tokenId, string calldata domain, bool rating, uint8 amount) internal {
        address avatarContract = repo().addressGet("avatar");
        try ISoul(avatarContract).repAdd(tokenId, domain, rating, amount) {}   //Failure should not be fatal
        catch Error(string memory /*reason*/) {}
    }

    //-- Upgrades

    /// Upgrade Incident Implementation
    function upgradeIncidentImplementation(address newImplementation) public onlyOwner {
        //Validate Interface
        // require(IERC165(newImplementation).supportsInterface(type(IIncident).interfaceId), "Implmementation Does Not Support Incident Interface");  //Would Cause Problems on Interface Update. Keep disabled for now.

        //Upgrade Beacon
        UpgradeableBeacon(beaconIncident).upgradeTo(newImplementation);
        //Upgrade Event
        emit UpdatedImplementation("incident", newImplementation);
    }

    /// Upgrade Game Implementation [TBD]
    function upgradeGameImplementation(address newImplementation) public onlyOwner {
        //Validate Interface
        // require(IERC165(newImplementation).supportsInterface(type(IIncident).interfaceId), "Implmementation Does Not Support Incident Interface");  //Would Cause Problems on Interface Update. Keep disabled for now.

        //Upgrade Beacon
        UpgradeableBeacon(beaconGame).upgradeTo(newImplementation);
        //Upgrade Event
        emit UpdatedImplementation("game", newImplementation);
    }

}