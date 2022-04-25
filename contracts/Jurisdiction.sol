//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;


// import "hardhat/console.sol";

// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";  //Track Token Supply & Check 
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IJurisdiction.sol";
import "./interfaces/IRules.sol";
import "./interfaces/ICase.sol";
// import "./libraries/DataTypes.sol";
// import "./abstract/Opinions.sol";
import "./abstract/ERC1155Roles.sol";
import "./abstract/CommonYJ.sol";
import "./abstract/Rules.sol";
import "./abstract/Rating.sol";
import "./abstract/Recursion.sol";


/**
 * @title Jurisdiction Contract
 * @dev Retains Group Members in Roles
 * @dev Version 0.6.0
 * V1: Role NFTs
 * - Mints Member NFTs
 * - One for each
 * - All members are the same
 * - Rules
 * - Creates new Cases
 * - Contract URI
 * - [TODO] Validation: Make Sure Account has an Avatar NFT
 * - [TODO] Token URIs for Roles
 * - [TODO] Unique Rule IDs (GUID)
 * V2:  
 * - [TODO] NFT Trackers - Assign Avatars instead of Accounts & Track the owner of the Avatar NFT
 */
contract Jurisdiction is IJurisdiction, Rules, Rating, CommonYJ, Recursion, ERC1155Roles {
    //--- Storage
    string public constant override symbol = "YJ_Jurisdiction";
    using Strings for uint256;

    using Counters for Counters.Counter;
    // Counters.Counter internal _tokenIds; //Track Last Token ID
    Counters.Counter internal _caseIds;  //Track Last Case ID
    
    // Contract name
    string public name;
    // Contract symbol
    // string public symbol;
    //Contract URI
    string internal _contract_uri;

    // mapping(string => uint256) internal _roles;     //NFTs as Roles
    // mapping(uint256 => address) internal _cases;      // Mapping for Case Contracts      //DEPRECATED - No need for Case IDs, Use Hash
    mapping(address => bool) internal _active;      // Mapping for Case Contracts

    // mapping(uint256 => string) internal _rulesURI;      // Mapping Metadata URIs for Individual Role 
    // mapping(uint256 => string) internal _uri;

    //Post Input Struct
    struct PostInput {
        string entRole;
        // string postRole;
        string uri;
    }

    //--- Functions

    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IJurisdiction).interfaceId || interfaceId == type(IRules).interfaceId || super.supportsInterface(interfaceId);
    }

    constructor(address hub, address actionRepo) CommonYJ(hub) ERC1155("") Rules(actionRepo){
        name = "Anti-Scam Jurisdiction";
        // symbol = "YJ_J1";
        //Init Default Jurisdiction Roles
        _roleCreate("creator");
        _roleCreate("member");
        _roleCreate("judge");
        //Assign Creator
        _roleAssign(tx.origin, "creator");
    }

    //** Case Functions

    /// Make a new Case & File it
    function caseMakeOpen(
        string calldata name_, 
        DataTypes.RuleRef[] calldata addRules, 
        DataTypes.InputRole[] calldata assignRoles, 
        PostInput[] calldata posts
    // ) public returns (uint256, address) {
    ) public returns (address) {
        //Make Case
        // (uint256 caseId, address caseContract) = caseMake(name_, addRules, assignRoles, posts);
        address caseContract = caseMake(name_, addRules, assignRoles, posts);
        //File Case
        ICase(caseContract).stageFile();
        //Return
        // return (caseId, caseContract);
        return caseContract;
    }

    /// Make a new Case
    function caseMake(
        string calldata name_, 
        DataTypes.RuleRef[] calldata addRules, 
        DataTypes.InputRole[] calldata assignRoles, 
        PostInput[] calldata posts
    // ) public returns (uint256, address) {
    ) public returns (address) {
        //TODO: Validate Caller Permissions (Member of Jurisdiction)
        // roleHas(_msgSender(), "admin")  
        // roleHas(_msgSender(), "member") 

        //Assign Case ID
        _caseIds.increment(); //Start with 1
        uint256 caseId = _caseIds.current();
        //Create new Case
        address caseContract = _HUB.caseMake(name_, addRules, assignRoles);
        //Remember Address
        // _cases[caseId] = caseContract;
        _active[caseContract] = true;
        //New Case Created Event
        emit CaseCreated(caseId, caseContract);
        //Posts
        for (uint256 i = 0; i < posts.length; ++i) {
            // ICase(caseContract).post(posts[i].entRole, posts[i].postRole, posts[i].uri);
            ICase(caseContract).post(posts[i].entRole, posts[i].uri);
        }
        // return (caseId, caseContract);
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
    function repAdd(address contractAddr, uint256 tokenId, DataTypes.Domain domain, DataTypes.Rating rating, uint8 amount) external {
        
        //TODO Validate - Called by Child Case


        //Run
        _repAdd(contractAddr, tokenId, domain, rating, amount);
    }

    //** Role Management

    /// Join a role in current jurisdiction
    function join() external override {
        _GUIDAssign(_msgSender(), _stringToBytes32("member"));
    }

    /// Leave Role in current jurisdiction
    function leave() external override {
        _GUIDRemove(_msgSender(), _stringToBytes32("member"));
    }

    /// Assign Someone Else to a Role
    function roleAssign(address account, string memory role) public override roleExists(role) {
        //Validate Permissions
        require(
            _msgSender() == account         //Self
            || owner() == _msgSender()      //Owner
            || roleHas(_msgSender(), "admin")    //Admin Role
            , "INVALID_PERMISSIONS");
        //Add
        _roleAssign(account, role);
    }

    /// Remove Someone Else from a Role
    function roleRemove(address account, string memory role) public override roleExists(role) {
        //Validate Permissions
        require(
            _msgSender() == account         //Self
            || owner() == _msgSender()      //Owner
            || balanceOf(_msgSender(), _roleToId("admin")) > 0     //Admin Token
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
    function ruleAdd(DataTypes.Rule memory rule, DataTypes.Confirmation memory confirmation) public override returns (uint256) {
        //Validate Caller's Permissions
        require(roleHas(_msgSender(), "admin"), "Admin Only");
        //Add Rule
        uint256 id = _ruleAdd(rule);
        //Set Confirmations
        _confirmationSet(id, confirmation);
        return id;
    }
    
    /// Update Rule
    function ruleUpdate(uint256 id, DataTypes.Rule memory rule) external override {
        //Validate Caller's Permissions
        require(roleHas(_msgSender(), "admin"), "Admin Only");
        //Update Rule
        _ruleUpdate(id, rule);
    }

    /// Get Token URI
    // function tokenURI(uint256 token_id) public view returns (string memory) {
    // function uri(uint256 token_id) public view returns (string memory) {
    //     require(exists(token_id), "NONEXISTENT_TOKEN");
    //     return _tokenURIs[token_id];
    // }
    
    /// Set Action's Metadata URI
    // function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
    //     require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
    //     _tokenURIs[tokenId] = _tokenURI;
    // }

    // function _actionSetURI(bytes32 guid, string memory uri) internal {
    //     _uri[_GUIDToId(guid)] = uri;
    //     emit ActionURI(guid, uri);
    // }

   /**
     * @dev Contract URI
     *  https://docs.opensea.io/docs/contract-level-metadata
     */
    function contractURI() public view override returns (string memory) {
        return _contract_uri;
    }
}