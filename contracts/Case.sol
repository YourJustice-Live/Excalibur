//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "./libraries/DataTypes.sol";
// import "./abstract/ERC1155Roles.sol";
import "./abstract/CommonYJUpgradable.sol";
import "./abstract/ERC1155RolesUpgradable.sol";
// import "./abstract/Rules.sol";
import "./interfaces/ICase.sol";
import "./interfaces/IRules.sol";
// import "./interfaces/IJurisdiction.sol";

/**
 * @title Case Contract
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
    // mapping(string => string) public roleName;      // Mapping Role Names //e.g. "subject"=>"seller"
    
    //--- Modifiers

    //--- Functions
    
    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ICase).interfaceId || interfaceId == type(IRules).interfaceId || super.supportsInterface(interfaceId);
    }

    /// Initializer
    function initialize (
        string memory name_, 
        string memory symbol_, 
        address hub 
        , DataTypes.RuleRef[] memory addRules
        , DataTypes.InputRole[] memory assignRoles

    ) public override initializer {
        // require(jurisdiction != address(0), "INVALID JURISDICTION");
        // _jurisdiction = _msgSender();   //Do I Even need this here? The jurisdiciton points to it's cases...

        //Initializers
        __ERC1155RolesUpgradable_init("");
        __CommonYJ_init(hub);

        //State
        name = name_;
        symbol = symbol_;

        //Init Default Case Roles
        _roleCreate("admin");
        _roleCreate("subject");     //Filing against
        _roleCreate("plaintiff");   //Filing the case
        _roleCreate("judge");       //Deciding authority
        _roleCreate("witness");     //Witnesses
        _roleCreate("affected");    //Affected Party [?]

        //Auto-Set Creator Wallet as Admin
        _roleAssign(tx.origin, "admin");
        _roleAssign(tx.origin, "plaintiff");

        //Assign Roles
        for (uint256 i = 0; i < assignRoles.length; ++i) {
            _roleAssign(assignRoles[i].account, assignRoles[i].role);
        }

        //Add Rules
        for (uint256 i = 0; i < addRules.length; ++i) {
            _ruleAdd(addRules[i].jurisdiction, addRules[i].ruleId);
        }
    }
    
    /// Assign to a Role
    function roleAssign(address account, string memory role) external override roleExists(role) {
        //Validate Permissions
        require(
            owner() == _msgSender()      //Owner
            || roleHas(_msgSender(), "admin")    //Admin Role
            // || msg.sender == address(_HUB)   //Through the Hub
            , "INVALID_PERMISSIONS");

        // console.log("Case Role Assign:", role);

        //Add
        _roleAssign(account, role);
    }

    // roleAssign()

    // roleRequest() => Event [Communication]

    // roleOffer() (Upon Reception)

    // roleAccept()


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

    /// Add Post 
    /// @param entRole  posting as entitiy in role (posting entity must be assigned to role)
    /// @param postRole i.e. post type (role:comment/evidence/decleration/etc')
    // function post(uint256 token_id, string calldata uri) public {
    function post(string calldata entRole, string calldata postRole, string calldata uri) external {
        //Validate: Sender Holds The Entity-Role 
        require(roleHas(_msgSender(), entRole), "ROLE:INVALID_PERMISSION");
        //Validate Stage
        require(stage < DataTypes.CaseStage.Closed, "STAGE:CASE_CLOSED");
        //Post Event
        emit Post(_msgSender(), entRole, postRole, uri);
    }

    //--- Rule Reference 

    /// Add Rule Reference
    function ruleAdd(address jurisdiction_, uint256 ruleId_) external {
        //TODO: Validate Jurisdiciton implements IRules (ERC165)

        //Validate
        require (_msgSender() == address(_HUB) || roleHas(_msgSender(), "admin") || owner() == _msgSender(), "EXPECTED HUB OR ADMIN");

        //Run
        _ruleAdd(jurisdiction_, ruleId_);
    }

    /// Add Relevant Rule Reference 
    function _ruleAdd(address jurisdiction_, uint256 ruleId_) internal {
        //Assign Rule Reference ID
        _ruleIds.increment(); //Start with 1
        uint256 ruleId = _ruleIds.current();

        //New Rule
        _rules[ruleId].jurisdiction = jurisdiction_;
        _rules[ruleId].ruleId = ruleId_;

        //Get Rule, Get Affected & Add as new Role if Doesn't Exist
        DataTypes.Rule memory rule = ruleGet(ruleId);
        if(!roleExist(rule.affected)){
            _roleCreate(rule.affected);
        }

        //Event: Rule Reference Added 
        emit RuleAdded(jurisdiction_, ruleId_);
    }
    
    //--- State Changers
    
    /// File the Case (Validate & Open Discussion)  --> Open
    function stageFile() public override {
        
        //TODO: Validate Caller
        
        require(stage == DataTypes.CaseStage.Draft, "STAGE:DRAFT_ONLY");

        //TODO: Validate Evidence & Witnesses

        //Case is now Open
        _setStage(DataTypes.CaseStage.Open);
    }

    /// Case Wait For Verdict  --> Pending
    function stageWaitForVerdict() public override {
        
        //TODO: Validate Caller
        
        require(stage == DataTypes.CaseStage.Open, "STAGE:OPEN_ONLY");
        //Case is now Waiting for Verdict
        _setStage(DataTypes.CaseStage.Verdict);
    }

    /// Case Stage: Place Verdict  --> Closed
    function stageVerdict(string calldata uri) public override {
        require(roleHas(_msgSender(), "judge") , "ROLE:JUDGE_ONLY");
        require(stage == DataTypes.CaseStage.Verdict, "STAGE:VERDICT_ONLY");

        //Case is now Closed
        _setStage(DataTypes.CaseStage.Closed);
        //Verdict Event
        emit Verdict(uri, _msgSender());

        //TODO: Update Avatar's Reputation

    }

    /// Change Case Stage
    function _setStage(DataTypes.CaseStage stage_) internal {
        //Set Stage
        stage = stage_;
        //Stage Change Event
        emit Stage(stage);
    }

    // function nextStage(string calldata uri) public {
        // if (sha3(myEnum) == sha3("Bar")) return MyEnum.Bar;
    // }

    /**
     * @dev Contract URI
     *  https://docs.opensea.io/docs/contract-level-metadata
     */ 
    function contractURI() public view override returns (string memory) {
        return _contract_uri;
    }

 
    //--- Dev Playground [WIP]

    /// TODO: Get Avatar NFT By Account
    // function xxx () returns () {}

    /* Should Inherit From J's Rules / Actions
    /// Set Role's Name Mapping
    function _entityMap(string memory role_, string memory name_) internal {
        roleName[role_] = name_;
    }
    */
   
}