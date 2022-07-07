//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
// import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IConfig.sol";
import "./interfaces/IAssoc.sol";
import "./interfaces/IAssocRepo.sol";
import "./interfaces/ICommonYJ.sol";
import "./interfaces/IHub.sol";
import "./interfaces/IGameUp.sol";
import "./interfaces/IIncident.sol";
import "./interfaces/IAvatar.sol";
import "./libraries/DataTypes.sol";
// import "./abstract/CommonYJ.sol";
import "./abstract/Assoc.sol";


/**
 * YJ Hub Contract
 * - Hold Known Contract Addresses (Avatar, History)
 * - Contract Factory (Games & Incidents)
 * - Remember Products (Games & Incidents)
 */
contract Hub is 
        IHub, 
        ERC165,
        Assoc,
        Ownable {


    

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
    string public constant override role = "Hub";
    string public constant override symbol = "HUB";

    //--- Storage
    // address internal _CONFIG;    //Configuration Contract
    IConfig private _CONFIG;  //Configuration Contract       //DEPRECATE

    mapping(address => bool) internal _games; // Mapping for Active Games   //[TBD]
    mapping(address => address) internal _incidents;      // Mapping for Incident Contracts  [C] => [J]


    //--- Events
    //TODO: Owner 
    //TODO: Config changed

    //--- Functions
 
    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IHub).interfaceId 
            || interfaceId == type(IAssoc).interfaceId 
            || super.supportsInterface(interfaceId);
    }

    constructor(address config, address gameContract, address incidentContract){
        //Set Protocol's Config Address
        _setConfig(config);
        //Init Game Contract Beacon
        UpgradeableBeacon _beaconJ = new UpgradeableBeacon(gameContract);
        beaconGame = address(_beaconJ);
        //Init Incident Contract Beacon
        UpgradeableBeacon _beaconC = new UpgradeableBeacon(incidentContract);
        beaconIncident = address(_beaconC);
    }

    /// @dev Returns the address of the current owner.
    function owner() public view override(IHub, Ownable) returns (address) {
        // return _CONFIG.owner();
        return IConfig(getConfig()).owner();
    }

    /// Get Configurations Contract Address
    function getConfig() public view returns (address) {
        // return _CONFIG;
        // return address(_CONFIG);
        return getAssoc("config");
    }

    /// Expose Configurations Set for Current Owner
    function setConfig(address config) public onlyOwner {
        _setConfig(config);
    }

    /// Set Configurations Contract Address
    function _setConfig(address config) internal {
        //Validate Contract's Designation
        require(keccak256(abi.encodePacked(IConfig(config).symbol())) == keccak256(abi.encodePacked("Config")), "Invalid Config Contract");
        //Set
        // _CONFIG = IConfig(config);
        _setAssoc("config", config);
    }

    /// Update Hub
    function hubChange(address newHubAddr) external override onlyOwner {
        //Avatar
        address avatarContract = getAssoc("avatar");
        if(avatarContract != address(0)){
            ICommonYJ(avatarContract).setHub(newHubAddr);
        }
        //History
        address actionRepo = getAssoc("history");
        if(actionRepo != address(0)){
            ICommonYJ(actionRepo).setHub(newHubAddr);
        }
        //Emit Hub Change Event
        emit HubChanged(newHubAddr);
    }

    //-- Assoc

    /// Set Association
    function setAssoc(string memory key, address contractAddr) external onlyOwner {
        _setAssoc(key, contractAddr);
    }

    //--- Factory 

    /// Make a new Game
    function gameMake(string calldata name_, string calldata uri_) external override returns (address) {
        //Validate
        // require(beaconGame != address(0), "Game Beacon Missing");      //Redundant
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

        //Validate
        // require(beaconIncident != address(0), "Incident Beacon Missing");    //Redundant

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

        //TODO: Validate - Known Game
        // require(_games[_msgSender()], "NOT A VALID JURISDICTION");

        // console.log("Hub: Add Reputation to Contract:", contractAddr, tokenId, amount);
        // console.log("Hub: Add Reputation in Domain:", domain);
        address avatarContract = getAssoc("avatar");
        //Update Avatar's Reputation    //TODO: Just Check if Contract Implements IRating
        if(avatarContract != address(0) && avatarContract == contractAddr){
            _repAddAvatar(tokenId, domain, rating, amount);
        }
    }

    /// Add Repuation to Avatar
    function _repAddAvatar(uint256 tokenId, string calldata domain, bool rating, uint8 amount) internal {
        address avatarContract = getAssoc("avatar");
        // require(avatarContract != address(0), "AVATAR_CONTRACT_UNKNOWN");
        // repAdd(avatarContract, tokenId, domain, rating, amount);
        // IAvatar(avatarContract).repAdd(tokenId, domain, rating, amount);
        try IAvatar(avatarContract).repAdd(tokenId, domain, rating, amount) {   //Failure should not be fatal
            // return "";
        } catch Error(string memory /*reason*/) {
        // } catch Error(string memory reason) {
            // console.log("Avatar Rep Change Failed W/" , reason);
            // return reason;
        }
    }

    //-- Upgrades

    /// Upgrade Incident Implementation
    function upgradeIncidentImplementation(address newImplementation) public onlyOwner {
        //Validate Interface
        // require(IERC165(newImplementation).supportsInterface(type(IIncident).interfaceId), "Implmementation Does Not Support Incident Interface");  //Might Cause Problems on Interface Update. Keep disabled for now.

        //Upgrade Beacon
        UpgradeableBeacon(beaconIncident).upgradeTo(newImplementation);
        //Upgrade Event
        // emit UpdatedIncidentImplementation(newImplementation);
        emit UpdatedImplementation("incident", newImplementation);
    }

    /// Upgrade Game Implementation [TBD]
    function upgradeGameImplementation(address newImplementation) public onlyOwner {
        //Validate Interface
        // require(IERC165(newImplementation).supportsInterface(type(IIncident).interfaceId), "Implmementation Does Not Support Incident Interface");  //Might Cause Problems on Interface Update. Keep disabled for now.

        //Upgrade Beacon
        UpgradeableBeacon(beaconGame).upgradeTo(newImplementation);
        //Upgrade Event
        emit UpdatedImplementation("game", newImplementation);
    }

}