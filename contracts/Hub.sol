//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IConfig.sol";
import "./interfaces/IHub.sol";
import "./interfaces/IJurisdiction.sol";
import "./interfaces/ICase.sol";
import "./libraries/DataTypes.sol";
import "./abstract/CommonYJ.sol";


/**
 * Case Contract
 * - [TODO] Hold Public Avatar NFT Contract Address
 */
// contract Hub is CommonYJ, Ownable{
contract Hub is IHub, Ownable {
    //---Storage
    address public beaconCase;
    // address public beaconJurisdiction;  //TBD

    //Avatar Contract Address
    address public override avatarContract;

    // using Counters for Counters.Counter;
    // Counters.Counter internal _tokenIds; //Track Last Token ID
    // Counters.Counter internal _caseIds;  //Track Last Case ID

    // Arbitrary contract designation signature
    string public constant override role = "YJHub";
    // string public constant symbol = "YJHub"; //TODO: Use This

    //--- Storage
    // address internal _CONFIG;    //Configuration Contract
    IConfig private _CONFIG;  //Configuration Contract       //Try This

    mapping(uint256 => address) private _jurisdictions; //Track all Jurisdiction contracts (on Creation)        //[TBD]
    // mapping(address => mapping(address => bool)) internal _active;      // Mapping for Case Contracts  [J][C] => bool
    mapping(address => address) internal _cases;      // Mapping for Case Contracts  [C] => [J]


    //--- Events
    //TODO: Owner 
    //TODO: Config changed

    //--- Functions

    constructor(address config, address caseContract){
        //Set Protocol's Config Address
        _setConfig(config);
        
        //Init Case Contract Beacon
        UpgradeableBeacon _beacon = new UpgradeableBeacon(caseContract);
        beaconCase = address(_beacon);
    }
    
    /// @dev Returns the address of the current owner.
    function owner() public view override(IHub, Ownable) returns (address) {
        return _CONFIG.owner();
        // address configContract = getConfig();
        // return IConfig(configContract).owner();
    }

    /// Set Avatar Contaract Address
    function setAvatarContract(address avatarContract_) external onlyOwner {
        require(avatarContract == address(0), "ADDRESS_ALREADY_SET");
        //Set
        avatarContract = avatarContract_;
    }

    /// Get Configurations Contract Address
    function getConfig() public view returns (address) {
        // return _CONFIG;
        return address(_CONFIG);
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
        _CONFIG = IConfig(config);
    }

    //--- Factory 

    /// Make a new Case
    function caseMake(
        string calldata name_
        , DataTypes.RuleRef[] memory addRules
        , DataTypes.InputRole[] memory assignRoles
    ) public override returns (address) {
        //TODO: Validate Caller Permissions (A Jurisdiction)

        //Rules

        //Assign Case ID
        // _caseIds.increment(); //Start with 1
        // uint256 caseId = _caseIds.current();

        //Validate
        require(beaconCase != address(0), "Case Beacon Missing");
        //Deploy
        BeaconProxy newCaseProxy = new BeaconProxy(
            beaconCase,
            abi.encodeWithSelector(
                ICase( payable(address(0)) ).initialize.selector,
                name_,          //Name
                "YJ_CASE",      //Symbol
                address(this),   //Hub
                addRules,
                assignRoles,
                _msgSender()    //Birth Parent (Container)
            )
        );

        //Remember
        // _active[msg.sender][address(newCaseProxy)] = true;
        _cases[address(newCaseProxy)] = msg.sender;

        //Return
        return address(newCaseProxy);
    }
    /// Add Repuation to Avatar
    function repAddAvatar(uint256 tokenId, DataTypes.Domain domain, DataTypes.Rating rating, uint8 amount) external {
        require(avatarContract != address(0), "AVATAR_CONTRACT_UNKNOWN");
        repAdd(avatarContract, tokenId, domain, rating, amount);
    }

    /// Add Reputation (Positive or Negative)       /// Opinion Updated
    function repAdd(address contractAddr, uint256 tokenId, DataTypes.Domain domain, DataTypes.Rating rating, uint8 amount) public {

        //TODO: Validate - Known Jurisdiction


        //TODO: Update Avatar's Reputation //?


        //Check if Jurisdiction is owned (Optional)
        

        //Check if Jurisdiction Ackgnoladges Case
        // IJurisdiction().caseHas(msg.sender);

        //Update Jurisdiction's Rating


        //Update Avatar's Rating
        // if(contractAddr == 'AvatarAccount')

    }

    //-- Upgrades

    /// Upgrade Case Implementation
    function upgradeCaseImplementation(address newImplementation) public onlyOwner {
        //Validate Interface
        // require(IERC165(newImplementation).supportsInterface(type(ICase).interfaceId), "Implmementation Does Not Support Case Interface");  //Might Cause Problems on Interface Update. Keep disabled for now.

        //Upgrade Beacon
        UpgradeableBeacon(beaconCase).upgradeTo(newImplementation);
        //Upgrade Event
        emit UpdatedCaseImplementation(newImplementation);
    }

    /// Upgrade Jurisdiction Implementation [TBD]
    // function upgradeCaseImplementation(address newImplementation) public onlyOwner {
        
    // }

}