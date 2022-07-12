//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
// import "@openzeppelin/contracts/governance/utils/Votes.sol";
// import "./abstract/Votes.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/draft-ERC721VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/utils/VotesUpgradeable.sol"; //Adds 3.486Kb
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "./interfaces/IGameUp.sol";
import "./interfaces/IRulesRepo.sol";
import "./interfaces/IReaction.sol";
import "./interfaces/IActionRepo.sol";
import "./public/interfaces/IVotesRepo.sol";
import "./abstract/ERC1155RolesTrackerUp.sol";
import "./abstract/ProtocolEntityUpgradable.sol";
import "./abstract/Opinions.sol";
import "./abstract/Posts.sol";
// import "./abstract/Rules.sol";
// import "./abstract/Recursion.sol";
// import "./public/interfaces/IOpenRepo.sol";
import "./abstract/ProxyMulti.sol";  //Adds 1.529Kb
// import "./libraries/DataTypes.sol";


/**
 * @title Game Contract
 * @dev Retains Group Members in Roles
 * @dev Version 3.0
 * V1: Using Role NFTs
 * - Mints Member NFTs
 * - One for each
 * - All members are the same
 * - Rules
 * - Creates new Reactions
 * - Contract URI
 * - Token URIs for Roles
 * - Owner account must have an Avatar NFT
 * V2: Trackers
 * - NFT Trackers - Assign Avatars instead of Accounts & Track the owner of the Avatar NFT
 * V3:
 * - Multi-Proxy Pattern
 * / DAO Votes [?]
 * V4:
 * - [TODO] Unique Rule IDs (GUID)
 */
contract GameUpgradable is 
        IGame, 
        IRules,
        ProtocolEntityUpgradable, 
        Opinions, 
        Posts,
        ProxyMulti,
        // VotesUpgradeable,
        ERC1155RolesTrackerUp {
        // ERC1155RolesUpgradable {

    //--- Storage
    string public constant override symbol = "GAME";
    using Strings for uint256;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    // CountersUpgradeable.Counter internal _tokenIds; //Track Last Token ID
    CountersUpgradeable.Counter internal _reactionIds;  //Track Last Reaction ID
    
    // Contract name
    string public name;
    // Mapping for Reaction Contracts
    mapping(address => bool) internal _active;

    //Post Input Struct
    struct PostInput {
        uint256 tokenId;
        string entRole;
        string uri;
    }

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


    /** For VotesUpgradeable
     * @dev Returns the balance of `account`.
     * /
    function _getVotingUnits(address account) internal view virtual override returns (uint256) {
        return balanceOf(account, _roleToId("member"));
    }
    */


    //Get Rules Repo
    function _ruleRepo() internal view returns (IRules) {
        address ruleRepoAddr = repo().addressGetOf(address(_HUB), "RULE_REPO");
        return IRules(ruleRepoAddr);
    }

    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IGame).interfaceId 
            || interfaceId == type(IRules).interfaceId 
            || super.supportsInterface(interfaceId);
    }

    /// Initializer
    function initialize (address hub, string calldata name_, string calldata uri_) public override initializer {
        //Initializers
        // __ERC1155RolesUpgradable_init("");
        __ProtocolEntity_init(hub);
        __setTargetContract(repo().addressGetOf(address(_HUB), "SBT"));
        
        //Init Recursion Controls
        // __Recursion_init(address(_HUB)); //CANCELLED

        //Set Contract URI
        _setContractURI(uri_);
        //Identifiers
        name = name_;
        //Init Default Game Roles
        _roleCreate("admin"); 
        _roleCreate("member");
        _roleCreate("authority");
        //Default Token URIs
        _setRoleURI("admin", "https://ipfs.io/ipfs/QmQcahBAJkXzSgwQn2zZ9D1m7friRCuW7rVia5KWNpWK7x");
        _setRoleURI("member", "https://ipfs.io/ipfs/QmbXVfwyTAfoYcThK7LZ2FAADoZPjbfbPJDcXWcwf79ssY");
        _setRoleURI("authority", "https://ipfs.io/ipfs/QmRVXii7PRTtaYRt5mD1yrAqy623itttjQX3hsnikYpi1x");
        //Assign Creator as Admin & Member
        _roleAssign(tx.origin, "admin", 1);
        _roleAssign(tx.origin, "member", 1);
    }

    //** Reaction Functions

    /// Make a new Reaction
    /// @dev a wrapper function for creation, adding rules, assigning roles & posting
    function reactionMake(
        string calldata name_, 
        string calldata uri_, 
        DataTypes.RuleRef[] calldata addRules, 
        DataTypes.InputRoleToken[] calldata assignRoles, 
        PostInput[] calldata posts
    ) public returns (address) {
        //Validate Caller Permissions (Member of Game)
        require(roleHas(_msgSender(), "member"), "Members Only");
        //Assign Reaction ID
        _reactionIds.increment(); //Start with 1
        uint256 reactionId = _reactionIds.current();
        //Create new Reaction
        address reactionContract = _HUB.reactionMake(name_, uri_, addRules, assignRoles);
        //Remember Address
        _active[reactionContract] = true;
        //New Reaction Created Event
        emit ReactionCreated(reactionId, reactionContract);
        //Posts
        for (uint256 i = 0; i < posts.length; ++i) {
            IReaction(reactionContract).post(posts[i].entRole, posts[i].tokenId, posts[i].uri);
        }
        return reactionContract;
    }
    
    /// Make a new Reaction & File it
    /// @dev a wrapper function for creation, adding rules, assigning roles, posting & filing a reaction
    function reactionMakeOpen(
        string calldata name_, 
        string calldata uri_, 
        DataTypes.RuleRef[] calldata addRules, 
        DataTypes.InputRoleToken[] calldata assignRoles, 
        PostInput[] calldata posts
    ) public returns (address) {
        //Make Reaction
        address reactionContract = reactionMake(name_, uri_, addRules, assignRoles, posts);
        //File Reaction
        IReaction(reactionContract).stageFile();
        //Return
        return reactionContract;
    }

    /// Disable Reaction        //TODO: Also Support Enable
    function reactionDisable(address reactionContract) public override onlyOwner {
        //Validate
        require(_active[reactionContract], "Reaction Not Active");
        _active[reactionContract] = false;
    }

    /// Check if Reaction is Owned by This Contract (& Active)
    function reactionHas(address reactionContract) public view override returns (bool){
        return _active[reactionContract];
    }

    /// Add Post 
    /// @param entRole  posting as entitiy in role (posting entity must be assigned to role)
    /// @param tokenId  Acting SBT Token ID
    /// @param uri_     post URI
    function post(string calldata entRole, uint256 tokenId, string calldata uri_) external override {
        //Validate that User Controls The Token
        require(ISoul( repo().addressGetOf(address(_HUB), "SBT") ).hasTokenControl(tokenId), "SOUL:NOT_YOURS");
        //Validate: Soul Assigned to the Role 
        require(roleHasByToken(tokenId, entRole), "ROLE:NOT_ASSIGNED");    //Validate the Calling Account
        // require(roleHasByToken(tokenId, entRole), string(abi.encodePacked("TOKEN: ", tokenId, " NOT_ASSIGNED_AS: ", entRole)) );    //Validate the Calling Account
        //Post Event
        _post(tx.origin, tokenId, entRole, uri_);
    }

    /// Get Token URI by Token ID
    // function tokenURI(uint256 token_id) public view returns (string memory) {
    // function uri(uint256 token_id) public view override returns (string memory) {
    function uri(uint256 token_id) public view returns (string memory) {
        // require(exists(token_id), "NONEXISTENT_TOKEN");
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

    //** Generic Config
    
    /// Generic Config Get Function
    function confGet(string memory key) public view override returns(string memory) {
        return repo().stringGet(key);
    }
    
    /// Generic Config Set Function
    function confSet(string memory key, string memory value) public override AdminOrOwner {
        _confSet(key, value);
    }

    //** Multi Proxy

    /// Proxy Fallback Implementations
    function _implementations() internal view virtual override returns (address[] memory){
        address[] memory implementationAddresses;
        string memory gameType = confGet("type");
        if(Utils.stringMatch(gameType, "")) return implementationAddresses;
        // require (!Utils.stringMatch(gameType, ""), "NO_GAME_TYPE");
        //UID
        string memory gameTypeFull = string(abi.encodePacked("GAME_", gameType));
        //Fetch Implementations
        implementationAddresses = repo().addressGetAllOf(address(_HUB), gameTypeFull); //Specific
        require(implementationAddresses.length > 0, "NO_FALLBACK_CONTRACT");
        return implementationAddresses;
    }

    /* Support for Global Extension
    /// Proxy Fallback Implementations
    function _implementations() internal view virtual override returns (address[] memory){
        //UID
        string memory gameType = string(abi.encodePacked("GAME_", confGet("type")));
        //Fetch Implementations
        address[] memory implementationAddresses = repo().addressGetAllOf(address(_HUB), gameType); //Specific
        address[] memory implementationAddressesAll = repo().addressGetAllOf(address(_HUB), "GAME_ALL"); //General
        return arrayConcat(implementationAddressesAll, implementationAddresses);
    }
    
    /// Concatenate Arrays (A Suboptimal Solution -- ~800Bytes)      //TODO: Maybe move to an external library?
    function arrayConcat(address[] memory Accounts, address[] memory Accounts2) private pure returns(address[] memory) {
        //Create a new container array
        address[] memory returnArr = new address[](Accounts.length + Accounts2.length);
        uint i=0;
        if(Accounts.length > 0){
            for (; i < Accounts.length; i++) {
                returnArr[i] = Accounts[i];
            }
        }
        uint j=0;
        if(Accounts2.length > 0){
            while (j < Accounts.length) {
                returnArr[i++] = Accounts2[j++];
            }
        }
        return returnArr;
    } 
    */


    //** Custom Rating Functions
    
    /// Add Reputation (Positive or Negative)
    function repAdd(address contractAddr, uint256 tokenId, string calldata domain, bool rating, uint8 amount) external override {
        //Validate - Called by Child Reaction
        require(reactionHas(_msgSender()), "NOT A VALID INCIDENT");
        //Run on Self
        _repAdd(contractAddr, tokenId, domain, rating, amount);
        //Update Hub
        _HUB.repAdd(contractAddr, tokenId, domain, rating, amount);
    }

    //** Role Management

    /// Join a game (as a regular 'member')
    function join() external override returns (uint256) {
        require (!Utils.stringMatch(confGet("isClosed"), "true"), "CLOSED_SPACE");
        //Mint Member Token to Self
        return _GUIDAssign(_msgSender(), _stringToBytes32("member"), 1);
    }

    /// Leave 'member' Role in game
    function leave() external override returns (uint256) {
        return _GUIDRemove(_msgSender(), _stringToBytes32("member"), 1);
    }

    /// Request to Join
    function nominate(uint256 soulToken, string memory uri_) external override {
        emit Nominate(_msgSender(), soulToken, uri_);
    }

    /// Assign Someone Else to a Role
    function roleAssign(address account, string memory role) public override roleExists(role) AdminOrOwner {
        _roleAssign(account, role, 1);
    }

    /// Assign Tethered Token to a Role
    function roleAssignToToken(uint256 ownerToken, string memory role) public override roleExists(role) AdminOrOwner {
        _roleAssignToToken(ownerToken, role, 1);
    }

    /// Remove Someone Else from a Role
    function roleRemove(address account, string memory role) public override roleExists(role) AdminOrOwner {
        _roleRemove(account, role, 1);
    }

    /// Remove Tethered Token from a Role
    function roleRemoveFromToken(uint256 ownerToken, string memory role) public override roleExists(role) AdminOrOwner {
        _roleRemoveFromToken(ownerToken, role, 1);
    }

    /// Change Role Wrapper (Add & Remove)
    function roleChange(address account, string memory roleOld, string memory roleNew) external override {
        roleAssign(account, roleNew);
        roleRemove(account, roleOld);
    }

    /** TODO: DEPRECATE - Allow Uneven Role Distribution 
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

    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._afterTokenTransfer(operator, from, to, ids, amounts, data);


        address votesRepoAddr = repo().addressGetOf(address(_HUB), "VOTES_REPO");
        if(votesRepoAddr != address(0)){
            for (uint256 i = 0; i < ids.length; ++i) {
                // uint256 id = ids[i];
                uint256 amount = amounts[i];
                //Votes Changes
                IVotesRepo(votesRepoAddr).transferVotingUnits(from, to, amount);
            }
        }
        else{
            console.log("No Votes Repo Configured", votesRepoAddr);
        }

    }


    //** Rule Management
    
    //-- Getters

    /// Get Rule
    function ruleGet(uint256 id) public view override returns (DataTypes.Rule memory) {
        return _ruleRepo().ruleGet(id);
    }

    /// Get Rule's Effects
    function effectsGet(uint256 id) public view override returns (DataTypes.Effect[] memory){
        return _ruleRepo().effectsGet(id);
    }

    /// Get Rule's Confirmation Method
    function confirmationGet(uint256 id) public view override returns (DataTypes.Confirmation memory){
        return _ruleRepo().confirmationGet(id);
    }

    //-- Setters

    /// Create New Rule
    function ruleAdd(
        DataTypes.Rule memory rule, 
        DataTypes.Confirmation memory confirmation, 
        DataTypes.Effect[] memory effects
    ) public override returns (uint256) {
        return _ruleRepo().ruleAdd(rule, confirmation, effects);
    }

    /// Update Rule
    function ruleUpdate(
        uint256 id, 
        DataTypes.Rule memory rule, 
        DataTypes.Effect[] memory effects
    ) external override {
        _ruleRepo().ruleUpdate(id, rule, effects);
    }

    /// Set Disable Status for Rule
    function ruleDisable(uint256 id, bool disabled) external override {
        _ruleRepo().ruleDisable(id, disabled);
    }

    /// Update Rule's Confirmation Data
    function ruleConfirmationUpdate(uint256 id, DataTypes.Confirmation memory confirmation) external override {
        _ruleRepo().ruleConfirmationUpdate(id, confirmation);
    }

    
}