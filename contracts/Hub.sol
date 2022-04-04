//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

// import "@openzeppelin/contracts/access/Ownable.sol";
// import {DataTypes} from './libraries/DataTypes.sol';
import "./libraries/DataTypes.sol";
import "./abstract/Rules.sol";
import "./abstract/CommonYJ.sol";
import "./interfaces/IConfig.sol";
import "./interfaces/IHub.sol";

import "./interfaces/ICase.sol";


/**
 * Case Contract
 * - [TODO] Hold Public Avatar NFT Contract Address
 */
// contract Hub is CommonYJ, Ownable{
contract Hub is IHub, Ownable {
    //---Storage
    address public beaconCase;

    // using Counters for Counters.Counter;
    // Counters.Counter internal _tokenIds; //Track Last Token ID
    // Counters.Counter internal _caseIds;  //Track Last Case ID

    // Arbitrary contract designation signature
    string public constant override role = "YJHub";
    // string public constant symbol = "YJHub"; //TODO: Use THis

    //--- Storage
    // address internal _CONFIG;    //Configuration Contract
    IConfig private _CONFIG;  //Configuration Contract       //Try This

    mapping(uint256 => address) private _jurisdictions; //Track all Jurisdiction contracts


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
    function caseMake(string calldata name_) public override returns (address) {
        //TODO: Validate Caller Permissions

console.log("HUB - Make Case()");

        //Rules

        //Role Mapping
        // Account -> Role + Rule Mapping??
        // DataTypes.RoleMappingInput[] memory roleMapping;

        //Assign Case ID
        // _caseIds.increment(); //Start with 1
        // uint256 caseId = _caseIds.current();

        /*
        //Make
        // MetaCoin metaCoin = new MetaCoin(metaCoinOwner, initialBalance);
        Case newCase = new Case( 
            name_, 
            string(abi.encodePacked("YJ_CASE", caseId.toString())), 
            _getHub(), 
            // address(this),
            roleMapping
        );
        */
        //Validate
        require(beaconCase != address(0), "Case Beacon Missing");
        //Deploy
        BeaconProxy newCaseProxy = new BeaconProxy(
            beaconCase,

            abi.encodeWithSelector(
                ICase( payable(address(0)) ).initialize.selector,
                name_, 
                "YJ_CASE", 
                address(this)
            )

            // abi.encodeWithSignature("initialize(string memory, string memory, address)", name_, "YJ_CASE", address(this))
        );

        
        //Return
        return address(newCaseProxy);

        // return address(0);  //[DEV]
    }
    
    /// Upgrade Case Beacon Implementation
    function upgradeCaseBeacon(address _newImplementation) public onlyOwner {
        //TODO: Validate? 

        //Upgrade Beacon
        UpgradeableBeacon(beaconCase).upgradeTo(_newImplementation);

        //Remember New Implementation's Address     //This seems wrong. The beacon doesn't change.
        // beaconCase = _newImplementation;
    }

}