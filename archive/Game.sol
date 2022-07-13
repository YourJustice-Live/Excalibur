//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";

// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";  //Track Token Supply & Check 
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IGame.sol";
import "./interfaces/IRules.sol";
import "./interfaces/IReaction.sol";
// import "./libraries/DataTypes.sol";
import "./abstract/ERC1155Roles.sol";
import "./abstract/ProtocolEntity.sol";
import "./abstract/Rules.sol";
import "./abstract/Opinions.sol";
import "./abstract/Recursion.sol";
import "./abstract/Posts.sol";


/**
 * @title Game Contract
 * @dev Retains Group Members in Roles
 * @dev Version 0.6.0
 * V1: Role NFTs
 * - Mints Member NFTs
 * - One for each
 * - All members are the same
 * - Rules
 * - Creates new Reactions
 * - Contract URI
 * - [TODO] Validation: Make Sure Account has an Avatar NFT
 * - [TODO] Token URIs for Roles
 * - [TODO] Unique Rule IDs (GUID)
 * V2:  
 * - [TODO] NFT Trackers - Assign Avatars instead of Accounts & Track the owner of the Avatar NFT
 */
contract Game is 
        IGame, 
        ProtocolEntity, 
        Rules, 
        Opinions, 
        Posts, 
        Recursion, 
        ERC1155Roles {

    //--- Storage
    string public constant override symbol = "GAME";
    using Strings for uint256;

    using Counters for Counters.Counter;
    // Counters.Counter internal _tokenIds; //Track Last Token ID
    Counters.Counter internal _reactionIds;  //Track Last Reaction ID
    
    // Contract name
    string public name;
    // Contract symbol
    // string public symbol;
    //Contract URI
    // string internal _contract_uri;

    // mapping(string => uint256) internal _roles;    //NFTs as Roles
    // mapping(uint256 => address) internal _reactions;   // Mapping for Reaction Contracts      //DEPRECATED - No need for Reaction IDs, Use Hash
    mapping(address => bool) internal _active;        // Mapping for Reaction Contracts

    // mapping(uint256 => string) internal _rulesURI; // Mapping Metadata URIs for Individual Role 
    // mapping(uint256 => string) internal _uri;

    //--- Functions

    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IGame).interfaceId 
            || interfaceId == type(IRules).interfaceId 
            || super.supportsInterface(interfaceId);
    }

    constructor(address hub, address actionRepo) ProtocolEntity(hub) ERC1155(""){
        //Fetch & Set Current History Contract
        // _setActionsContract(_HUB.historyContract());
        // _setActionsContract(actionRepo); //CANCELLED
        name = "Anti-Scam Game";
        //Init Default Game Roles
        _roleCreate("admin"); 
        _roleCreate("member");
        _roleCreate("authority");
        //Assign Creator as First Admin
        _roleAssign(tx.origin, "admin");
    }

    //** Reaction Functions

    /// Make a new Reaction & File it
    function reactionMakeOpen(
        string calldata name_, 
        DataTypes.RuleRef[] calldata addRules, 
        DataTypes.InputRole[] calldata assignRoles, 
        PostInput[] calldata posts
    // ) public returns (uint256, address) {
    ) public returns (address) {
        //Make Reaction
        address reactionContract = reactionMake(name_, addRules, assignRoles, posts);
        //File Reaction
        IReaction(reactionContract).stageFile();
        //Return
        return reactionContract;
    }

    /// Make a new Reaction
    function reactionMake(
        string calldata name_, 
        DataTypes.RuleRef[] calldata addRules, 
        DataTypes.InputRole[] calldata assignRoles, 
        PostInput[] calldata posts
    ) public returns (address) {
        //TODO: Validate Caller Permissions (Member of Game)
        // roleHas(_msgSender(), "admin")
        // roleHas(_msgSender(), "member")

        //Assign Reaction ID
        _reactionIds.increment(); //Start with 1
        uint256 reactionId = _reactionIds.current();
        //Create new Reaction
        address reactionContract = _HUB.reactionMake(name_, addRules, assignRoles);
        //Remember Address
        // _reactions[reactionId] = reactionContract;
        _active[reactionContract] = true;
        //New Reaction Created Event
        emit ReactionCreated(reactionId, reactionContract);
        //Posts
        for (uint256 i = 0; i < posts.length; ++i) {
            IReaction(reactionContract).post(posts[i].entRole, posts[i].tokenId, posts[i].uri);
        }
        return reactionContract;
    }
    
    /// Disable Reaction
    function reactionDisable(address reactionContract) public override onlyOwner {
        //Validate
        require(_active[reactionContract], "Reaction Not Active");
        _active[reactionContract] = false;
    }

    /// Check if Reaction is Owned by This Contract (& Active)
    function reactionHas(address reactionContract) public view override returns (bool){
        return _active[reactionContract];
    }

    //** Custom Rating Functions
    
    /// Add Reputation (Positive or Negative)
    // function repAdd(address contractAddr, uint256 tokenId, string calldata domain, DataTypes.Rating rating, uint8 amount) external override {
    function repAdd(address contractAddr, uint256 tokenId, string calldata domain, bool rating, uint8 amount) external override {
        //Validate - Called by Child Reaction
        require(reactionHas(_msgSender()), "NOT A VALID INCIDENT");
        //Run
        _repAdd(contractAddr, tokenId, domain, rating, amount);
        //Update Hub
        _HUB.repAdd(contractAddr, tokenId, domain, rating, amount);
    }

    //** Role Management

    /// Join a role in current game
    function join() external override {
        _GUIDAssign(_msgSender(), _stringToBytes32("member"));
    }

    /// Leave Role in current game
    function leave() external override {
        _GUIDRemove(_msgSender(), _stringToBytes32("member"));
    }

    /// Assign Someone Else to a Role
    function roleAssign(address account, string memory role) public override roleExists(role) {
        //Validate Permissions
        require(owner() == _msgSender()      //Owner
            || roleHas(_msgSender(), "admin")    //Admin Role
            , "INVALID_PERMISSIONS");
        //Add
        _roleAssign(account, role);
    }

    /// Remove Someone Else from a Role
    function roleRemove(address account, string memory role) public override roleExists(role) {
        //Validate Permissions
        require(owner() == _msgSender()      //Owner
            || balanceOf(_msgSender(), _roleToId("admin")) > 0     //Admin Role
            , "INVALID_PERMISSIONS");
        //Remove
        _roleRemove(account, role);
    }

    /// Change Role Wrapper (Add & Remove)
    function roleChange(address account, string memory roleOld, string memory roleNew) external override {
        roleAssign(account, roleNew);
        roleRemove(account, roleOld);
    }

    /**
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
        if (to != address(0)) {
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
        //Add Rule
        uint256 id = _ruleAdd(rule, effects);
        //Set Confirmations
        _confirmationSet(id, confirmation);
        return id;
    }
    
    /// Update Rule
    // function ruleUpdate(uint256 id, DataTypes.Rule memory rule) external override {
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