//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "./interfaces/ICase.sol";
// import "./interfaces/IJurisdiction.sol";
import "./interfaces/IRules.sol";
// import "./libraries/DataTypes.sol";
// import "./abstract/ERC1155Roles.sol";
import "./abstract/CommonYJUpgradable.sol";
import "./abstract/ERC1155RolesUpgradable.sol";
import "./abstract/Rules.sol";

/**
 * Case Contract
 */
contract Case is ICase, CommonYJUpgradable, ERC1155RolesUpgradable {


    //-- Rule Reference (in a Case)
    // {
    // 	ruleId: 1, 
    // 	jurisdictionId: 1
    // }

    //--- Storage

    using Counters for Counters.Counter;
    Counters.Counter internal _ruleIds;  //Track Last Rule ID

    // Contract name
    string public name;
    // Contract symbol
    string public symbol;
    //Jurisdiction
    address private _jurisdiction;

    //Stage (Case Lifecycle)
    DataTypes.CaseStage public stage;

    //Rules Reference
    mapping(uint256 => DataTypes.RuleRef) internal _rules;      // Mapping for Case Contracts

    //Rule's Role Mapping
    // subject: 'xxx'
    // affected[ruleId] => 'zzz'        //(in Rule Ref)

    mapping(string => string) public roleName;      // Mapping Role Names //e.g. "subject"=>"seller"
    
    //--- Events


    //--- Functions
    
    // constructor(
    function initialize (
        string memory name_, 
        string memory symbol_, 
        address hub 
        // DataTypes.RoleMappingInput[] memory roleNames
    // ) CommonYJ(hub) ERC1155Roles("") {
    ) public override initializer {
        // require(jurisdiction != address(0), "INVALID JURISDICTION");
        //TODO: Validate Jurisdiciton implements IRules (ERC165)
        //TODO: Maybe Validate Caller (Hub / Jurisdiction)
        // _jurisdiction = jurisdiction;   //Do I Even need this here? The jurisdiciton points to it's cases...
        
        // __ERC1155_init("");
        // __Ownable_init();
        __ERC1155RolesUpgradable_init("");
        __CommonYJ_init(hub);
    /*
        // roleName
        for (uint256 i = 0; i < roleNames.length; ++i) {
            // roleName[roleNames[i].role] = roleNames[i].name;
            _entityMap(roleNames[i].role, roleNames[i].name);
        }
    */
        name = name_;
        symbol = symbol_;

        //Init Default Case Roles
        _roleCreate("admin");
        _roleCreate("subject");     //Filing against
        _roleCreate("plaintiff");   //Filing the case
        _roleCreate("authority");   //Managing / deciding authority
        _roleCreate("witness");     //Witnesses
        // _roleCreate("affected");    //Affected Party [?]

    }
    
    /// Check if Reference ID exists
    function ruleRefExist(uint256 ruleRefId) internal view returns (bool){
        return (_rules[ruleRefId].jurisdiction != address(0) && _rules[ruleRefId].ruleId != 0);
    }

    /// Fetch Rule By Reference ID
    function ruleGet(uint256 ruleRefId) public view returns (DataTypes.Rule memory){
        //Validate
        require (ruleRefExist(ruleRefId), "INEXISTENT_RULE_REF_ID");
        return IRules(_rules[ruleRefId].jurisdiction).ruleGet(_rules[ruleRefId].ruleId);
    }

    /// Get Rule's Confirmation Data
    function ruleGetConfirmation(uint256 ruleRefId) public view returns (DataTypes.Confirmation memory){
        //Validate
        require (ruleRefExist(ruleRefId), "INEXISTENT_RULE_REF_ID");
        return IRules(_rules[ruleRefId].jurisdiction).confirmationGet(_rules[ruleRefId].ruleId);
    }

    /// Set Role's Name Mapping
    function _entityMap(string memory role_, string memory name_) internal {
        roleName[role_] = name_;
    }

    //--- Dev Playground [WIP]


    //[role] => {Entity entity, name:roleName}
    //[subject] => {Entity entity, name:'Seller'}
    mapping(uint256 => RoleMapping) internal _roleMapping;      // Mapping Roles to Entities
    struct RoleMapping {
        DataTypes.Entity entity;
        string name;
    //     Entity subject;
    //     // Entity plaintif;
    //     Entity affected;
    //     entity witness;
    }
    // struct Entity{
    //     address account; //Contract
    //     uint256 id; //token ID
    //     uint256 chain; //Chain ID
    //     // string role;    //Textual Role [witness/]
    // }
    /// Add Relevant Rule Reference 
    function _ruleAddRef(address jurisdiction_, uint256 ruleId_, DataTypes.Entity storage affected_) internal {

        //Assign Rule Reference ID
        _ruleIds.increment(); //Start with 1
        uint256 ruleId = _ruleIds.current();

        // RuleRef {
        //     address jurisdiction;
        //     uint256 ruleId;
        //     Entity affected: {
        //         address account;
        //         uint256 id;
        //         uint256 chain;
        //     }
        // }

        // struct Entity 
        _rules[ruleId].jurisdiction = jurisdiction_;
        _rules[ruleId].ruleId = ruleId_;
        _rules[ruleId].affected = affected_;
        
        //Assign Affected to a Role? 

        // _roleMapping["witness"].name = "witness";   //?
        // _roleMapping["subject"].name = "seller";
        // _roleMapping["subject"].name = "seller";



    }

    /// TODO: Add Post (Type:Comment, Evidence, Decleration, etc')
    
    /**
     * Post - Owner can Post
     */
    // function post(uint256 token_id, string calldata uri) public {
    function post(address account, string calldata uri) public {
        //Event
        // emit Post(uri, token_id);
        // emit Post(uri, account);
    }
}