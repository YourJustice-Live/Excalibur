//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "./libraries/DataTypes.sol";
import "./interfaces/IReaction.sol";
import "./interfaces/IRules.sol";
import "./interfaces/ISoul.sol";
import "./interfaces/IERC1155RolesTracker.sol";
import "./interfaces/IGameUp.sol";
import "./abstract/ProtocolEntityUpgradable.sol";
import "./abstract/ERC1155RolesTrackerUp.sol";
import "./abstract/Posts.sol";

/**
 * @title Upgradable Reaction Contract
 * @dev Version 1.1
 */
contract ReactionUpgradable is 
    IReaction, 
    Posts, 
    ProtocolEntityUpgradable, 
    ERC1155RolesTrackerUp {

    //--- Storage
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter internal _ruleIds;  //Track Last Rule ID

    // Contract name
    string public name;
    // Contract symbol
    // string public symbol;
    string public constant symbol = "REACTION";

    //Game
    // address private _game;
    //Contract URI
    // string internal _contract_uri;

    //Stage (Reaction Lifecycle)
    DataTypes.ReactionStage public stage;

    //Rules Reference
    mapping(uint256 => DataTypes.RuleRef) internal _rules;      // Mapping for Reaction Rules
    mapping(uint256 => bool) public decision;                   // Mapping for Rule Decisions
    
    //--- Modifiers

    /// Check if GUID Exists
    modifier AdminOrOwner() {
       //Validate Permissions
        require(owner() == _msgSender()      //Owner
            || roleHas(_msgSender(), "admin")    //Admin Role
            , "INVALID_PERMISSIONS");
        _;
    }

    //--- Functions
    
    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IReaction).interfaceId 
            || interfaceId == type(IRules).interfaceId 
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
        //Initializers
        __ProtocolEntity_init(hub);
        __setTargetContract(getSoulAddr());
        //Set Parent Container
        _setParentCTX(container);
        
        //Set Contract URI
        _setContractURI(uri_);
        //Identifiers
        name = name_;
        //Init Default Reaction Roles
        _roleCreate("admin");
        _roleCreate("creator");     //Filing the reaction
        _roleCreate("subject");     //Acting Agent
        _roleCreate("authority");   //Deciding authority
        _roleCreate("witness");     //Witnesses
        _roleCreate("affected");    //Affected Party [?]
        //Auto-Set Creator Wallet as Admin
        _roleAssign(tx.origin, "admin", 1);
        _roleAssign(tx.origin, "creator", 1);
        //Assign Roles
        for (uint256 i = 0; i < assignRoles.length; ++i) {
            _roleAssignToToken(assignRoles[i].tokenId, assignRoles[i].role, 1);

        }
        //Add Rules
        for (uint256 i = 0; i < addRules.length; ++i) {
            _ruleAdd(addRules[i].game, addRules[i].ruleId);
        }
    }

    /* Maybe, When used more than once
    /// Set Association
    function _setAssoc(string memory key, address contractAddr) internal {
        repo().addressSet(key, contractAddr);
    }

    /// Get Contract Association
    function getAssoc(string memory key) public view override returns(address) {
        //Return address from the Repo
        return repo().addressGet(key);
    }
    */
    
    /// Set Parent Container
    function _setParentCTX(address container) internal {
        //Validate
        require(container != address(0), "Invalid Container Address");
        require(IERC165(container).supportsInterface(type(IGame).interfaceId), "Implmementation Does Not Support Game Interface");  //Might Cause Problems on Interface Update. Keep disabled for now.
        //Set to OpenRepo
        repo().addressSet("container", container);
        // _setAssoc("container", container);
    }
    
    /// Get Container Address
    function getContainerAddr() internal view returns(address){
        // return _game;
        return repo().addressGet("container");
    }

    /// Get Soul Contract Address
    function getSoulAddr() internal view returns(address){
        return repo().addressGetOf(address(_HUB), "SBT");
    }

    /// Request to Join
    function nominate(uint256 soulToken, string memory uri_) external override {
        emit Nominate(_msgSender(), soulToken, uri_);
    }

    /// Assign to a Role
    function roleAssign(address account, string memory role) public override roleExists(role) {
        //Special Validations for Special Roles 
        if (Utils.stringMatch(role, "admin") || Utils.stringMatch(role, "authority")){
            require(getContainerAddr() != address(0), "Unknown Parent Container");
            //Validate: Must Hold same role in Containing Game
            require(IERC1155RolesTracker(getContainerAddr()).roleHas(account, role), "User Required to hold same role in the Game context");
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
    function roleAssignToToken(uint256 ownerToken, string memory role) public override roleExists(role) AdminOrOwner {
        _roleAssignToToken(ownerToken, role, 1);
    }
    
    /// Remove Tethered Token from a Role
    function roleRemoveFromToken(uint256 ownerToken, string memory role) public override roleExists(role) AdminOrOwner {
        _roleRemoveFromToken(ownerToken, role, 1);
    }

    /// Check if Reference ID exists
    function ruleRefExist(uint256 ruleRefId) internal view returns (bool){
        return (_rules[ruleRefId].game != address(0) && _rules[ruleRefId].ruleId != 0);
    }

    /// Fetch Rule By Reference ID
    function ruleGet(uint256 ruleRefId) public view returns (DataTypes.Rule memory){
        //Validate
        require (ruleRefExist(ruleRefId), "INEXISTENT_RULE_REF_ID");
        return IRules(_rules[ruleRefId].game).ruleGet(_rules[ruleRefId].ruleId);
    }

    /// Get Rule's Confirmation Data
    function ruleGetConfirmation(uint256 ruleRefId) public view returns (DataTypes.Confirmation memory){
        //Validate
        require (ruleRefExist(ruleRefId), "INEXISTENT_RULE_REF_ID");
        return IRules(_rules[ruleRefId].game).confirmationGet(_rules[ruleRefId].ruleId);
    }

    /// Get Rule's Effects
    function ruleGetEffects(uint256 ruleRefId) public view returns (DataTypes.Effect[] memory){
        //Validate
        require (ruleRefExist(ruleRefId), "INEXISTENT_RULE_REF_ID");
        return IRules(_rules[ruleRefId].game).effectsGet(_rules[ruleRefId].ruleId);
    }

    // function post(string entRole, string uri) 
    // - Post by account + role (in the reaction, since an account may have multiple roles)

    // function post(uint256 token_id, string entRole, string uri) 
    //- Post by Entity (Token ID or a token identifier struct)
    
    /// Add Post 
    /// @param entRole  posting as entitiy in role (posting entity must be assigned to role)
    /// @param tokenId  Acting SBT Token ID
    /// @param uri_     post URI
    function post(string calldata entRole, uint256 tokenId, string calldata uri_) external override {
        //Validate that User Controls The Token
        // require(_hasTokenControl(tokenId), "SOUL:NOT_YOURS");
        // require(ISoul( IAssoc(address(_HUB)).getAssoc("SBT") ).hasTokenControl(tokenId), "SOUL:NOT_YOURS");
        require(ISoul( getSoulAddr() ).hasTokenControl(tokenId), "SOUL:NOT_YOURS");
        //Validate: Soul Assigned to the Role 
        // require(roleHas(tx.origin, entRole), "ROLE:NOT_ASSIGNED");    //Validate the Calling Account
        require(roleHasByToken(tokenId, entRole), "ROLE:NOT_ASSIGNED");    //Validate the Calling Account
        //Validate Stage
        require(stage < DataTypes.ReactionStage.Closed, "STAGE:CLOSED");
        //Post Event
        _post(tx.origin, tokenId, entRole, uri_);
    }

    //--- Rule Reference 

    /// Add Rule Reference
    function ruleAdd(address game_, uint256 ruleId_) external {
        //Validate Jurisdiciton implements IRules (ERC165)
        require(IERC165(game_).supportsInterface(type(IRules).interfaceId), "Implmementation Does Not Support Rules Interface");  //Might Cause Problems on Interface Update. Keep disabled for now.
        //Validate Sender
        require (_msgSender() == address(_HUB) 
            || roleHas(_msgSender(), "admin") 
            || owner() == _msgSender(), "EXPECTED HUB OR ADMIN");
        //Run
        _ruleAdd(game_, ruleId_);
    }

    /// Add Relevant Rule Reference 
    function _ruleAdd(address game_, uint256 ruleId_) internal {
        //Assign Rule Reference ID
        _ruleIds.increment(); //Start with 1
        uint256 ruleId = _ruleIds.current();
        //New Rule
        _rules[ruleId].game = game_;
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
        emit RuleAdded(game_, ruleId_);
    }
    
    //--- State Changers
    
    /// File the Reaction (Validate & Open Discussion)  --> Open
    function stageFile() public override {
        //Validate Caller
        require(roleHas(tx.origin, "creator") || roleHas(_msgSender(), "admin") , "ROLE:CREATOR_OR_ADMIN");
        //Validate Lifecycle Stage
        require(stage == DataTypes.ReactionStage.Draft, "STAGE:DRAFT_ONLY");
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
        //Reaction is now Open
        _setStage(DataTypes.ReactionStage.Open);
    }

    /// Reaction Wait For Verdict  --> Pending
    function stageWaitForVerdict() public override {
        //Validate Stage
        require(stage == DataTypes.ReactionStage.Open, "STAGE:OPEN_ONLY");
        //Validate Caller
        require(roleHas(_msgSender(), "authority") || roleHas(_msgSender(), "admin") , "ROLE:AUTHORITY_OR_ADMIN");
        //Reaction is now Waiting for Verdict
        _setStage(DataTypes.ReactionStage.Verdict);
    }   

    /// Reaction Stage: Place Verdict  --> Closed
    // function stageVerdict(string calldata uri) public override {
    function stageVerdict(DataTypes.InputDecision[] calldata verdict, string calldata uri_) public override {
        require(roleHas(_msgSender(), "authority") , "ROLE:AUTHORITY_ONLY");
        require(stage == DataTypes.ReactionStage.Verdict, "STAGE:VERDICT_ONLY");

        //Process Verdict
        for (uint256 i = 0; i < verdict.length; ++i) {
            decision[verdict[i].ruleId] = verdict[i].decision;
            if(verdict[i].decision){
                // Rule Confirmed
                _ruleConfirmed(verdict[i].ruleId);
            }
        }

        //Reaction is now Closed
        _setStage(DataTypes.ReactionStage.Closed);
        //Emit Verdict Event
        emit Verdict(uri_, _msgSender());
    }

    /// Reaction Stage: Reject Reaction --> Cancelled
    function stageCancel(string calldata uri_) public override {
        require(roleHas(_msgSender(), "authority") , "ROLE:AUTHORITY_ONLY");
        require(stage == DataTypes.ReactionStage.Verdict, "STAGE:VERDICT_ONLY");
        //Reaction is now Closed
        _setStage(DataTypes.ReactionStage.Cancelled);
        //Cancellation Event
        emit Cancelled(uri_, _msgSender());
    }

    /// Change Reaction Stage
    function _setStage(DataTypes.ReactionStage stage_) internal {
        //Set Stage
        stage = stage_;
        //Stage Change Event
        emit Stage(stage);
    }

    /// Rule (Action) Confirmed (Currently Only Judging Avatars)
    function _ruleConfirmed(uint256 ruleId) internal {
        //Get Avatar Contract
        // ISoul avatarContract = ISoul(_HUB.getAssoc("SBT"));
        // ISoul avatarContract = ISoul(IAssoc(address(_HUB)).getAssoc("SBT"));
        ISoul avatarContract = ISoul( getSoulAddr() );
        

        /* REMOVED for backward compatibility while in dev mode.
        //Validate Avatar Contract Interface
        require(IERC165(address(avatarContract)).supportsInterface(type(ISoul).interfaceId), "Invalid Avatar Contract");
        */

        //Fetch Reaction's Subject(s)
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
                    //Register Rep in Game      //{name:'professional', value:5, direction:false}
                    IGame(getContainerAddr()).repAdd(address(avatarContract), tokenId, effect.name, direction, effect.value);
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
    function setRoleURI(string memory role, string memory _tokenURI) external override AdminOrOwner {
        _setRoleURI(role, _tokenURI);
    }
   
    /// Set Contract URI
    function setContractURI(string calldata contract_uri) external override AdminOrOwner {
        _setContractURI(contract_uri);
    }

    // function nextStage(string calldata uri) public {
        // if (sha3(myEnum) == sha3("Bar")) return MyEnum.Bar;
    // }

}