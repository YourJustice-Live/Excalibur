//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "./libraries/DataTypes.sol";
import "./abstract/CommonYJUpgradable.sol";
import "./abstract/ERC1155RolesUpgradable.sol";
import "./interfaces/ICase.sol";
import "./interfaces/IRules.sol";
import "./interfaces/IAvatar.sol";
import "./interfaces/IERC1155Roles.sol";
import "./interfaces/IJurisdiction.sol";

/**
 * @title Case Contract
 * @dev Version 0.2.0
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
    mapping(uint256 => DataTypes.RuleRef) internal _rules;      // Mapping for Case Rules
    mapping(uint256 => bool) public decision;                   // Mapping for Rule Decisions
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
        , address container
    ) public override initializer {
        //Set Parent Container
        _setParentCTX(container);
        //Initializers
        __ERC1155RolesUpgradable_init("");
        __CommonYJ_init(hub);
        //Identifiers
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

    /// Set Parent Container
    function _setParentCTX(address container) internal {
        //Validate
        require(container != address(0), "Invalid Container Address");
        require(IERC165(container).supportsInterface(type(IJurisdiction).interfaceId), "Implmementation Does Not Support Jurisdiction Interface");  //Might Cause Problems on Interface Update. Keep disabled for now.
        //Set        
        _jurisdiction = container;
    }
    
    /// Assign to a Role
    function roleAssign(address account, string memory role) external override roleExists(role) {
        //Validate Permissions
        require(
            owner() == _msgSender()      //Owner
            || roleHas(_msgSender(), "admin")    //Admin Role
            // || msg.sender == address(_HUB)   //Through the Hub
            , "INVALID_PERMISSIONS");

        //Special Validations
        if (keccak256(abi.encodePacked(role)) == keccak256(abi.encodePacked("judge"))){
            require(_jurisdiction != address(0), "Unknown Parent Container");
            //Validate: Must Hold same role in Containing Jurisdiction
            require(IERC1155Roles(_jurisdiction).roleHas(account, role), "User Required to hold same role in Jurisdiction");
        }

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
    // function post(uint256 token_id, string calldata uri) external override {     //Post by Token ID (May later use Entity GUID as Caller)
    // function post(string calldata entRole, string calldata postRole, string calldata uri) external override {        //Explicit postRole
    function post(string calldata entRole, string calldata uri) external override {     //postRole in the URI
        //Validate: Sender Holds The Entity-Role 
        // require(roleHas(_msgSender(), entRole), "ROLE:INVALID_PERMISSION");
        require(roleHas(tx.origin, entRole), "ROLE:INVALID_PERMISSION");    //Validate the Calling Account
        //Validate Stage
        require(stage < DataTypes.CaseStage.Closed, "STAGE:CASE_CLOSED");
        //Post Event
        // emit Post(_msgSender(), entRole, postRole, uri);
        // emit Post(tx.origin, entRole, postRole, uri);
        emit Post(tx.origin, entRole, uri);
    }

    // function post(string entRole, string uri) 
    // - Post by account + role (in the case, since an account may have multiple roles)

    // function post(uint256 token_id, string entRole, string uri) 
    //- Post by Entity (Token ID or a token identifier struct)


    //--- Rule Reference 

    /// Add Rule Reference
    function ruleAdd(address jurisdiction_, uint256 ruleId_) external {
        //Validate Jurisdiciton implements IRules (ERC165)
        require(IERC165(jurisdiction_).supportsInterface(type(IRules).interfaceId), "Implmementation Does Not Support Rules Interface");  //Might Cause Problems on Interface Update. Keep disabled for now.
        //Validate Sender
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
        //Validate Caller
        require(roleHas(_msgSender(), "plaintiff") , "ROLE:PLAINTIFF_ONLY");
        //Validate Lifecycle Stage
        require(stage == DataTypes.CaseStage.Draft, "STAGE:DRAFT_ONLY");
        //Validate Witnesses
        for (uint256 ruleId = 1; ruleId <= _ruleIds.current(); ++ruleId) {
            // DataTypes.Rule memory rule = ruleGet(ruleId);
            DataTypes.Confirmation memory confirmation = ruleGetConfirmation(ruleId);
            //Get Current Witness Headcount (Unique)
            uint256 witnesses = uniqueRoleMembersCount("witness");
            //Validate Min Witness Requirements
            require(witnesses >= confirmation.witness, "INSUFFICIENT_WITNESSES");
        }
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
    // function stageVerdict(string calldata uri) public override {
    function stageVerdict(DataTypes.InputDecision[] calldata verdict, string calldata uri) public override {
        require(roleHas(_msgSender(), "judge") , "ROLE:JUDGE_ONLY");
        require(stage == DataTypes.CaseStage.Verdict, "STAGE:VERDICT_ONLY");

        //Process Verdict
        for (uint256 i = 0; i < verdict.length; ++i) {
            decision[verdict[i].ruleId] = verdict[i].decision;
            if(verdict[i].decision){
                // Rule Confirmed
                _ruleConfirmed(verdict[i].ruleId);
            }
        }

        //Case is now Closed
        _setStage(DataTypes.CaseStage.Closed);
        //Emit Verdict Event
        emit Verdict(uri, _msgSender());
    }

    /// Case Stage: Reject Case --> Cancelled
    function stageCancel(string calldata uri) public override {
        require(roleHas(_msgSender(), "judge") , "ROLE:JUDGE_ONLY");
        require(stage == DataTypes.CaseStage.Verdict, "STAGE:VERDICT_ONLY");
        //Case is now Closed
        _setStage(DataTypes.CaseStage.Cancelled);
        //Cancellation Event
        emit Cancelled(uri, _msgSender());
    }

    /// Change Case Stage
    function _setStage(DataTypes.CaseStage stage_) internal {
        //Set Stage
        stage = stage_;
        //Stage Change Event
        emit Stage(stage);
    }

    /// Rule (Action) Confirmed
    function _ruleConfirmed(uint256 ruleId) internal {

        // DataTypes.Rule memory rule = ruleGet(ruleId);
        
        // _rules[ruleId].jurisdiction = jurisdiction_;
        // _rules[ruleId].ruleId = ruleId_;
        
        //Get Avatar Contract
        IAvatar avatarContract = IAvatar(_HUB.avatarContract());
        //Validate Avatar Contract Interface
        require(IERC165(address(avatarContract)).supportsInterface(type(IAvatar).interfaceId), "Invalid Avatar Contract");


        console.log("Case: Rule Confirmed:", ruleId);

        //Fetch Case's Subject(s)
        address[] memory subjects = uniqueRoleMembers("subject");
        //Each Subject
        for (uint256 i = 0; i < subjects.length; ++i) {

            //TODO! Get Token ID For Subject
            uint256 tokenId = avatarContract.tokenByAddress(subjects[i]);


            console.log("Case: Update Rep for Subject:", subjects[i], tokenId);
            // console.log("Case: Update Rep for Subject:", subjects[i]);
            // console.log("Case: Update Rep for Subject Token:", tokenId);
            if(tokenId > 0){
                DataTypes.Rule memory rule = ruleGet(ruleId);
                
                //O1 - Run on each Domain

                //O2 - Enum for Domains (Domain)
                // for(){
                    //Register Rep in Jurisdiction
                    // IJurisdiction(_jurisdiction).repAdd(address(avatarContract), tokenId, rule.effects.domain, rule.effects.rating, rule.effects.amount);
                // }
            }

        }
        
        //Rule Confirmed Event
        emit RuleConfirmed(ruleId);
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

    /* Should Inherit From J's Rules / Actions
    /// Set Role's Name Mapping
    function _entityMap(string memory role_, string memory name_) internal {
        roleName[role_] = name_;
    }
    */
   
}