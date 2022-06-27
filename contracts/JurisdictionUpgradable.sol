//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";

// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";  //Track Token Supply & Check 
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IJurisdictionUp.sol";
import "./interfaces/IRules.sol";
import "./interfaces/ICase.sol";
import "./interfaces/IAssoc.sol";
import "./interfaces/IActionRepo.sol";
// import "./libraries/DataTypes.sol";
// import "./abstract/ERC1155RolesUpgradable.sol";
import "./abstract/ERC1155RolesTrackerUp.sol";
import "./abstract/CommonYJUpgradable.sol";
import "./abstract/Rules.sol";
import "./abstract/ContractBase.sol";
import "./abstract/Opinions.sol";
// import "./abstract/Recursion.sol";
// import "./abstract/Posts.sol";


/**
 * @title Jurisdiction Contract
 * @dev Retains Group Members in Roles
 * @dev Version 2.1
 * V1: Role NFTs
 * - Mints Member NFTs
 * - One for each
 * - All members are the same
 * - Rules
 * - Creates new Cases
 * - Contract URI
 * - Token URIs for Roles
 * - Owner account must have an Avatar NFT
 * - [TODO] Unique Rule IDs (GUID)
 * V2:  
 * - [TODO] NFT Trackers - Assign Avatars instead of Accounts & Track the owner of the Avatar NFT
 */
contract JurisdictionUpgradable is 
        IJurisdiction, 
        Rules, 
        ContractBase,
        CommonYJUpgradable, 
        Opinions, 
        // Recursion,      //DEPRECATE / Cleanp
        // Posts,
        ERC1155RolesTrackerUp {
        // ERC1155RolesUpgradable {

    //--- Storage
    string public constant override symbol = "YJ_JURISDICTION";
    using Strings for uint256;

    using Counters for Counters.Counter;
    // Counters.Counter internal _tokenIds; //Track Last Token ID
    Counters.Counter internal _caseIds;  //Track Last Case ID
    
    // Contract name
    string public name;
    // Contract symbol
    // string public symbol;

    // mapping(string => uint256) internal _roles;    //NFTs as Roles
    // mapping(uint256 => address) internal _cases;   // Mapping for Case Contracts      //DEPRECATED - No need for Case IDs, Use Hash
    mapping(address => bool) internal _active;        // Mapping for Case Contracts

    //Post Input Struct
    struct PostInput {
        uint256 tokenId;
        string entRole;
        string uri;
    }

    //--- Functions

    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IJurisdiction).interfaceId 
            || interfaceId == type(IRules).interfaceId 
            || super.supportsInterface(interfaceId);
    }

    /// Initializer
    function initialize (address hub, string calldata name_, string calldata uri_) public override initializer {
        //Initializers
        // __ERC1155RolesUpgradable_init("");
        __CommonYJ_init(hub);
        __setTargetContract(IAssoc(address(_HUB)).getAssoc("avatar"));
        
        //Init Recursion Controls
        // __Recursion_init(address(_HUB)); //DEPRECATED

        //Set Contract URI
        _setContractURI(uri_);
        //Identifiers
        name = name_;
        //Init Default Jurisdiction Roles
        _roleCreate("admin"); 
        _roleCreate("member");
        _roleCreate("judge");
        //Default Token URIs
        _setRoleURI("admin", "https://ipfs.io/ipfs/QmQcahBAJkXzSgwQn2zZ9D1m7friRCuW7rVia5KWNpWK7x");
        _setRoleURI("member", "https://ipfs.io/ipfs/QmbXVfwyTAfoYcThK7LZ2FAADoZPjbfbPJDcXWcwf79ssY");
        _setRoleURI("judge", "https://ipfs.io/ipfs/QmRVXii7PRTtaYRt5mD1yrAqy623itttjQX3hsnikYpi1x");
        //Assign Creator as Admin & Member
        _roleAssign(tx.origin, "admin", 1);
        _roleAssign(tx.origin, "member", 1);
    }

    //** Case Functions

    /// Make a new Case
    /// @dev a wrapper function for creation, adding rules, assigning roles & posting
    function caseMake(
        string calldata name_, 
        string calldata uri_, 
        DataTypes.RuleRef[] calldata addRules, 
        DataTypes.InputRoleToken[] calldata assignRoles, 
        PostInput[] calldata posts
    ) public returns (address) {
        //Validate Caller Permissions (Member of Jurisdiction)
        require(roleHas(_msgSender(), "member"), "Members Only");
        //Assign Case ID
        _caseIds.increment(); //Start with 1
        uint256 caseId = _caseIds.current();
        //Create new Case
        address caseContract = _HUB.caseMake(name_, uri_, addRules, assignRoles);
        //Remember Address
        // _cases[caseId] = caseContract;
        _active[caseContract] = true;
        //New Case Created Event
        emit CaseCreated(caseId, caseContract);
        //Posts
        for (uint256 i = 0; i < posts.length; ++i) {
            ICase(caseContract).post(posts[i].entRole, posts[i].tokenId, posts[i].uri);
        }
        return caseContract;
    }
    
    /// Make a new Case & File it
    /// @dev a wrapper function for creation, adding rules, assigning roles, posting & filing a case
    function caseMakeOpen(
        string calldata name_, 
        string calldata uri_, 
        DataTypes.RuleRef[] calldata addRules, 
        DataTypes.InputRoleToken[] calldata assignRoles, 
        PostInput[] calldata posts
    // ) public returns (uint256, address) {
    ) public returns (address) {
        //Make Case
        address caseContract = caseMake(name_, uri_, addRules, assignRoles, posts);
        //File Case
        ICase(caseContract).stageFile();
        //Return
        return caseContract;
    }

    /// Disable Case
    function caseDisable(address caseContract) public override onlyOwner {
        //Validate
        require(_active[caseContract], "Case Not Active");
        _active[caseContract] = false;
    }

    /// Check if Case is Owned by This Contract (& Active)
    function caseHas(address caseContract) public view override returns (bool){
        return _active[caseContract];
    }

    //** Custom Rating Functions
    
    /// Add Reputation (Positive or Negative)
    // function repAdd(address contractAddr, uint256 tokenId, string calldata domain, DataTypes.Rating rating, uint8 amount) external override {
    function repAdd(address contractAddr, uint256 tokenId, string calldata domain, bool rating, uint8 amount) external override {
        //Validate - Called by Child Case
        require(caseHas(_msgSender()), "NOT A VALID CASE");
        //Run on Self
        _repAdd(contractAddr, tokenId, domain, rating, amount);
        //Update Hub
        _HUB.repAdd(contractAddr, tokenId, domain, rating, amount);
    }

    //** Role Management

     /// Join a role in current jurisdiction
    function join() external override returns (uint256) {
        return _GUIDAssign(_msgSender(), _stringToBytes32("member"), 1);
    }

    /// Leave Role in current jurisdiction
    function leave() external override returns (uint256) {
        return _GUIDRemove(_msgSender(), _stringToBytes32("member"), 1);
    }

    /// Assign Someone Else to a Role
    function roleAssign(address account, string memory role) public override roleExists(role) {
        //Validate Permissions
        require(owner() == _msgSender()      //Owner
            || roleHas(_msgSender(), "admin")    //Admin Role
            , "INVALID_PERMISSIONS");
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

    /// Remove Someone Else from a Role
    function roleRemove(address account, string memory role) public override roleExists(role) {
        //Validate Permissions
        require(owner() == _msgSender()      //Owner
            || balanceOf(_msgSender(), _roleToId("admin")) > 0     //Admin Role
            , "INVALID_PERMISSIONS");
        //Remove
        _roleRemove(account, role, 1);
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

    /// Change Role Wrapper (Add & Remove)
    function roleChange(address account, string memory roleOld, string memory roleNew) external override {
        roleAssign(account, roleNew);
        roleRemove(account, roleOld);
    }

    /** DEPRECATE - Allow Uneven Role Distribution 
    * @dev Hook that is called before any token transfer. This includes minting and burning, as well as batched variants.
    *  - Max of Single Token for each account
    */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
    super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        // if (to != address(0) && to != _targetContract){ //Not Burn
        if (_isOwnerAddress(to)){ //Not Burn
            for (uint256 i = 0; i < ids.length; ++i) {
                //Validate - Max of 1 Per Account
                uint256 id = ids[i];
                require(balanceOf(to, id) == 0, "ALREADY_ASSIGNED_TO_ROLE");
                uint256 amount = amounts[i];
                require(amount == 1, "ONE_TOKEN_MAX");
            }
        }
    }

    //** Rule Management

    /// Create New Rule
    function ruleAdd(
        DataTypes.Rule memory rule, 
        DataTypes.Confirmation memory confirmation, 
        DataTypes.Effect[] memory effects
    ) public override returns (uint256) {
        //Validate Caller's Permissions
        require(roleHas(_msgSender(), "admin"), "Admin Only");

        //Validate rule.about -- actionGUID Exists
        address actionRepo = IAssoc(address(_HUB)).getAssoc("history");
        IActionRepo(actionRepo).actionGet(rule.about);  //Revetrs if does not exist

        //Add Rule
        uint256 id = _ruleAdd(rule, effects);
        //Set Confirmations
        _confirmationSet(id, confirmation);
        return id;
    }

    /// Update Rule
    function ruleUpdate(
        uint256 id, 
        DataTypes.Rule memory rule, 
        DataTypes.Effect[] memory effects
    ) external override {
        //Validate Caller's Permissions
        require(roleHas(_msgSender(), "admin"), "Admin Only");
        //Update Rule
        _ruleUpdate(id, rule, effects);
    }

    /// Set Disable Status for Rule
    function ruleDisable(uint256 id, bool disabled) external {
         //Validate Caller's Permissions
        require(roleHas(_msgSender(), "admin"), "Admin Only");
        //Disable Rule
        _ruleDisable(id, disabled);
    }

    /// Update Rule's Confirmation Data
    function ruleConfirmationUpdate(uint256 id, DataTypes.Confirmation memory confirmation) external override {
        //Validate Caller's Permissions
        require(roleHas(_msgSender(), "admin"), "Admin Only");
        //Set Confirmations
        _confirmationSet(id, confirmation);
    }

    /*
    /// TODO: Update Rule's Effects
    function ruleEffectsUpdate(uint256 id, DataTypes.Effect[] memory effects) external override {
        //Validate Caller's Permissions
        require(roleHas(_msgSender(), "admin"), "Admin Only");
        //Set Effects
        
    }
    */

    /// Get Token URI by Token ID
    // function tokenURI(uint256 token_id) public view returns (string memory) {
    // function uri(uint256 token_id) public view override returns (string memory) {
    function uri(uint256 token_id) public view returns (string memory) {
        // require(exists(token_id), "NONEXISTENT_TOKEN");
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
    
}