//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
// import "./libraries/DataTypes.sol";
// import "./abstract/ERC1155Roles.sol";
import "./abstract/CommonYJUpgradable.sol";
import "./abstract/ERC1155RolesUpgradable.sol";
import "./abstract/Rules.sol";
import "./interfaces/ICase.sol";
import "./interfaces/IRules.sol";
// import "./interfaces/IJurisdiction.sol";


/**
 * Case Contract
 */
contract Case is ICase, CommonYJUpgradable, ERC1155RolesUpgradable {

    //--- Storage

    using Counters for Counters.Counter;
    Counters.Counter internal _ruleIds;  //Track Last Rule ID

    // Contract name
    string public name;
    // Contract symbol
    string public symbol;
    //Jurisdiction
    address private _jurisdiction;
    //Contract URI
    string internal _contract_uri;

    //Stage (Case Lifecycle)
    DataTypes.CaseStage public stage;

    //Rules Reference
    mapping(uint256 => DataTypes.RuleRef) internal _rules;      // Mapping for Case Contracts
    mapping(string => string) public roleName;      // Mapping Role Names //e.g. "subject"=>"seller"
    
    //--- Modifiers

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
        // _jurisdiction = msg.sender;   //Do I Even need this here? The jurisdiciton points to it's cases...
        
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
        _roleCreate("judge");       //Deciding authority
        _roleCreate("witness");     //Witnesses
        _roleCreate("affected");    //Affected Party [?]

        //Auto-Set Creator as Admin
        _roleAssign(tx.origin, "admin");
        _roleAssign(tx.origin, "plaintiff");
    }
    
    /// Assign to a Role
    function roleAssign(address account, string memory role) external override roleExists(role) {
        //Validate Permissions
        require(
            owner() == _msgSender()      //Owner
            || roleHas(_msgSender(), "admin")    //Admin Role
            // || msg.sender == address(_HUB)   //Through the Hub
            , "INVALID_PERMISSIONS");

        console.log("Case Role Assign:", role);

        //Add
        _roleAssign(account, role);
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

    /* Should Inherit From J's Rules / Actions
    /// Set Role's Name Mapping
    function _entityMap(string memory role_, string memory name_) internal {
        roleName[role_] = name_;
    }
    */

    /// Add Post (role:comment/evidence/decleration/etc')
    // function post(uint256 token_id, string calldata uri) public {
    function post(address account, string calldata role, string calldata uri) public {
        //Validate: Holds a Role in case

        //Event
        emit Post(account, role, uri);
        // emit Post(token_id, uri);
    }

    
    /// Fetch Role Mapping (entity name to slot name)
    // function getRoleMapping(string role) internal view returns (bool){
        
        //From Rule

        //From Action

    // }


    //--- Dev Playground [WIP]

    /// Set Role's Name Mapping
    // function _ruleRefSet(string memory role_, string memory name_) internal {
    //     roleName[role_] = name_;
    // }

    /// Add Rule Reference
    // function ruleAdd(address jurisdiction_, uint256 ruleId_, DataTypes.Entity calldata affected_) external {
    function ruleAdd(address jurisdiction_, uint256 ruleId_, string calldata affected_) external {
        //TODO: Validate Jurisdiciton implements IRules (ERC165)

        //Validate
        require (msg.sender == address(_HUB) || roleHas(_msgSender(), "admin") || owner() == _msgSender(), "EXPECTED HUB OR ADMIN");

        //Run
        _ruleAdd(jurisdiction_, ruleId_, affected_);
    }

    /// Add Relevant Rule Reference 
    // function _ruleAdd(address jurisdiction_, uint256 ruleId_, DataTypes.Entity calldata affected_) internal {
    function _ruleAdd(address jurisdiction_, uint256 ruleId_, string calldata affected_) internal {
        //Assign Rule Reference ID
        _ruleIds.increment(); //Start with 1
        uint256 ruleId = _ruleIds.current();

        //New Rule
        _rules[ruleId].jurisdiction = jurisdiction_;
        _rules[ruleId].ruleId = ruleId_;
        _rules[ruleId].affected = affected_;
        
        // RuleRef {
        //     address jurisdiction;
        //     uint256 ruleId;
        //     Entity affected: {
        //         address account;
        //         uint256 id;
        //         uint256 chain;
        //     }
        // }

        //Assign Affected to a Role? 

        // _roleMapping["witness"].name = "witness";   //?
        // _roleMapping["subject"].name = "seller";
        // _roleMapping["subject"].name = "seller";
    }

    //--- [DEV] Entity Mapping
    /*
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
    */
    
}