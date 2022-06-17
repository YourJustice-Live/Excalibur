//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

// import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "./libraries/DataTypes.sol";
import "./interfaces/ICase.sol";
import "./interfaces/IRules.sol";
import "./interfaces/IAvatar.sol";
import "./interfaces/IERC1155RolesTracker.sol";
import "./interfaces/IJurisdictionUp.sol";
// import "./interfaces/IJurisdiction.sol";
import "./interfaces/IAssoc.sol";
// import "./abstract/ContractBase.sol";
import "./abstract/CommonYJUpgradable.sol";
// import "./abstract/ERC1155RolesUpgradable.sol";
import "./abstract/ERC1155RolesTrackerUp.sol";
import "./abstract/Posts.sol";

/**
 * @title Upgradable Case Contract
 * @dev Version 1.1
 */
contract CaseUpgradable is 
    ICase, 
    Posts, 
    // ContractBase,    //Redundant
    CommonYJUpgradable, 
    ERC1155RolesTrackerUp {
    // ERC1155RolesUpgradable {

    //--- Storage
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter internal _ruleIds;  //Track Last Rule ID

    // Contract name
    string public name;
    // Contract symbol
    // string public symbol;
    string public constant symbol = "YJ_CASE";

    //Jurisdiction
    address private _jurisdiction;
    //Contract URI
    // string internal _contract_uri;

    //Stage (Case Lifecycle)
    DataTypes.CaseStage public stage;

    //Rules Reference
    mapping(uint256 => DataTypes.RuleRef) internal _rules;      // Mapping for Case Rules
    mapping(uint256 => bool) public decision;                   // Mapping for Rule Decisions
    
    //--- Modifiers

    //--- Functions
    
    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ICase).interfaceId 
            || interfaceId == type(IRules).interfaceId 
            || interfaceId == type(IAssoc).interfaceId 
            || super.supportsInterface(interfaceId);
    }

    /// Initializer
    function initialize (
        address hub, 
        string memory name_, 
        string calldata uri_, 
        DataTypes.RuleRef[] memory addRules, 
        DataTypes.InputRoleToken[] memory assignRoles, 
        address container
    ) public override initializer {
        //Set Parent Container
        _setParentCTX(container);
        //Initializers
        __CommonYJ_init(hub);
        // __setTargetContract(_HUB.getAssoc("avatar"));
        __setTargetContract(IAssoc(address(_HUB)).getAssoc("avatar"));
        //Set Contract URI
        _setContractURI(uri_);
        //Identifiers
        name = name_;
        //Init Default Case Roles
        _roleCreate("admin");
        _roleCreate("subject");     //Filing against
        _roleCreate("plaintiff");   //Filing the case
        _roleCreate("judge");       //Deciding authority
        _roleCreate("witness");     //Witnesses
        _roleCreate("affected");    //Affected Party [?]
        //Auto-Set Creator Wallet as Admin
        _roleAssign(tx.origin, "admin", 1);
        _roleAssign(tx.origin, "plaintiff", 1);
        //Assign Roles
        for (uint256 i = 0; i < assignRoles.length; ++i) {
            _roleAssignToToken(assignRoles[i].tokenId, assignRoles[i].role, 1);

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

        //TODO: Use OpenRepo

    }

    /// Assign to a Role
    function roleAssign(address account, string memory role) public override roleExists(role) {
        //Special Validations for 'judge' role
        if (keccak256(abi.encodePacked(role)) == keccak256(abi.encodePacked("judge"))){
            require(_jurisdiction != address(0), "Unknown Parent Container");
            //Validate: Must Hold same role in Containing Jurisdiction
            require(IERC1155RolesTracker(_jurisdiction).roleHas(account, role), "User Required to hold same role in Jurisdiction");
        }
        else{
            //Validate Permissions
            require(
                owner() == _msgSender()      //Owner
                || roleHas(_msgSender(), "admin")    //Admin Role
                // || msg.sender == address(_HUB)   //Through the Hub
                , "INVALID_PERMISSIONS");
        }
        //Add
        _roleAssign(account, role, 1);
    }
    
    /// Assign Tethered Token to a Role
    function roleAssignToToken(uint256 ownerToken, string memory role) public override roleExists(role) {
        //Validate Permissions
        require(owner() == _msgSender()      //Owner
            || roleHas(_msgSender(), "admin")    //Admin Role
            , "INVALID_PERMISSIONS");
        _roleAssignToToken(ownerToken, role, 1);
    }
    
    /// Remove Tethered Token from a Role
    function roleRemoveFromToken(uint256 ownerToken, string memory role) public override roleExists(role) {
        //Validate Permissions
        require(owner() == _msgSender()      //Owner
            || balanceOf(_msgSender(), _roleToId("admin")) > 0     //Admin Role
            , "INVALID_PERMISSIONS");
        //Remove
        _roleRemoveFromToken(ownerToken, role, 1);
    }

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

    /// Get Rule's Effects
    function ruleGetEffects(uint256 ruleRefId) public view returns (DataTypes.Effect[] memory){
        //Validate
        require (ruleRefExist(ruleRefId), "INEXISTENT_RULE_REF_ID");
        return IRules(_rules[ruleRefId].jurisdiction).effectsGet(_rules[ruleRefId].ruleId);
    }

    // function post(string entRole, string uri) 
    // - Post by account + role (in the case, since an account may have multiple roles)

    // function post(uint256 token_id, string entRole, string uri) 
    //- Post by Entity (Token ID or a token identifier struct)
    
    /// Check if the Current Account has Control over a Token
    function _hasTokenControl(uint256 tokenId) internal view returns (bool){
        address ownerAccount = _getAccount(tokenId);
        return (
            // ownerAccount == _msgSender()    //Token Owner
            ownerAccount == tx.origin    //Token Owner (Allows it to go therough the hub)
            || (ownerAccount == _targetContract && owner() == _msgSender()) //Unclaimed Token Controlled by Contract Owner/DAO
        );
    }
    
    /// Add Post 
    /// @param entRole  posting as entitiy in role (posting entity must be assigned to role)
    function post(string calldata entRole, uint256 tokenId, string calldata uri_) external override {     //postRole in the URI
        //Validate that User Controls The Token
        require(_hasTokenControl(tokenId), "SOUL:NOT_YOURS");
        //Validate: Sender Holds The Entity-Role 
        // require(roleHas(_msgSender(), entRole), "ROLE:INVALID_PERMISSION");
        require(roleHas(tx.origin, entRole), "ROLE:NOT_ASSIGNED");    //Validate the Calling Account
        //Validate Stage
        require(stage < DataTypes.CaseStage.Closed, "STAGE:CASE_CLOSED");

        //Post Event
        // emit Post(_msgSender(), entRole, postRole, uri_);
        // emit Post(tx.origin, entRole, postRole, uri_);
        // emit Post(tx.origin, entRole, uri_);
        _post(tx.origin, tokenId, entRole, uri_);
    }

    //--- Rule Reference 

    /// Add Rule Reference
    function ruleAdd(address jurisdiction_, uint256 ruleId_) external {
        //Validate Jurisdiciton implements IRules (ERC165)
        require(IERC165(jurisdiction_).supportsInterface(type(IRules).interfaceId), "Implmementation Does Not Support Rules Interface");  //Might Cause Problems on Interface Update. Keep disabled for now.
        //Validate Sender
        require (_msgSender() == address(_HUB) 
            || roleHas(_msgSender(), "admin") 
            || owner() == _msgSender(), "EXPECTED HUB OR ADMIN");
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
        //Validate Rule Active
        require(rule.disabled == false, "Selected rule is disabled");
        if(!roleExist(rule.affected)){
            //Create Affected Role if Missing
            _roleCreate(rule.affected);
        }
        //Event: Rule Reference Added 
        emit RuleAdded(jurisdiction_, ruleId_);
    }
    
    //--- State Changers
    
    /// File the Case (Validate & Open Discussion)  --> Open
    function stageFile() public override {
        //Validate Caller
        require(roleHas(tx.origin, "plaintiff") || roleHas(_msgSender(), "admin") , "ROLE:PLAINTIFF_OR_ADMIN");
        //Validate Lifecycle Stage
        require(stage == DataTypes.CaseStage.Draft, "STAGE:DRAFT_ONLY");
        //Validate - Has Subject
        require(uniqueRoleMembersCount("subject") > 0 , "ROLE:MISSING_SUBJECT");
        //Validate - Prevent Self Report? (subject != affected)

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
        //Validate Stage
        require(stage == DataTypes.CaseStage.Open, "STAGE:OPEN_ONLY");
        //TODO: Validate Caller
        // require(roleHas(tx.origin, "judge") || roleHas(_msgSender(), "admin") , "ROLE:JUDGE_OR_ADMIN");
        //Case is now Waiting for Verdict
        _setStage(DataTypes.CaseStage.Verdict);
    }   

    /// Case Stage: Place Verdict  --> Closed
    // function stageVerdict(string calldata uri) public override {
    function stageVerdict(DataTypes.InputDecision[] calldata verdict, string calldata uri_) public override {
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
        emit Verdict(uri_, _msgSender());
    }

    /// Case Stage: Reject Case --> Cancelled
    function stageCancel(string calldata uri_) public override {
        require(roleHas(_msgSender(), "judge") , "ROLE:JUDGE_ONLY");
        require(stage == DataTypes.CaseStage.Verdict, "STAGE:VERDICT_ONLY");
        //Case is now Closed
        _setStage(DataTypes.CaseStage.Cancelled);
        //Cancellation Event
        emit Cancelled(uri_, _msgSender());
    }

    /// Change Case Stage
    function _setStage(DataTypes.CaseStage stage_) internal {
        //Set Stage
        stage = stage_;
        //Stage Change Event
        emit Stage(stage);
    }

    /// Rule (Action) Confirmed (Currently Only Judging Avatars)
    function _ruleConfirmed(uint256 ruleId) internal {
        //Get Avatar Contract
        // IAvatar avatarContract = IAvatar(_HUB.getAssoc("avatar"));
        IAvatar avatarContract = IAvatar(IAssoc(address(_HUB)).getAssoc("avatar"));

        /* REMOVED for backward compatibility while in dev mode.
        //Validate Avatar Contract Interface
        require(IERC165(address(avatarContract)).supportsInterface(type(IAvatar).interfaceId), "Invalid Avatar Contract");
        */

        //Fetch Case's Subject(s)
        uint256[] memory subjects = uniqueRoleMembers("subject");
        //Each Subject
        for (uint256 i = 0; i < subjects.length; ++i) {
            //Get Subject's Token ID For 
            // uint256 tokenId = avatarContract.tokenByAddress(subjects[i]);
            uint256 tokenId = subjects[i];
            if(tokenId > 0){
                DataTypes.Effect[] memory effects = ruleGetEffects(ruleId);
                //Run Each Effect
                for (uint256 j = 0; j < effects.length; ++j) {
                    DataTypes.Effect memory effect = effects[j];
                    bool direction = effect.direction;
                    //Register Rep in Jurisdiction      //{name:'professional', value:5, direction:false}
                    IJurisdiction(_jurisdiction).repAdd(address(avatarContract), tokenId, effect.name, direction, effect.value);
                }
            }

        }
        
        //Rule Confirmed Event
        emit RuleConfirmed(ruleId);
    }

    /// Get Token URI by Token ID
    function uri(uint256 token_id) public view returns (string memory) {
        return _tokenURIs[token_id];
    }
    
    /// Set Metadata URI For Role
    function setRoleURI(string memory role, string memory _tokenURI) external override {
        //Validate Permissions
        require(owner() == _msgSender()      //Owner
            || roleHas(_msgSender(), "admin")    //Admin Role
            , "INVALID_PERMISSIONS");
        _setRoleURI(role, _tokenURI);
    }
   
    /// Set Contract URI
    function setContractURI(string calldata contract_uri) external override {
        //Validate Permissions
        require( owner() == _msgSender()      //Owner
            || roleHas(_msgSender(), "admin")    //Admin Role
            , "INVALID_PERMISSIONS");
        //Set
        _setContractURI(contract_uri);
    }

    // function nextStage(string calldata uri) public {
        // if (sha3(myEnum) == sha3("Bar")) return MyEnum.Bar;
    // }

}