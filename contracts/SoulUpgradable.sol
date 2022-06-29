// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./interfaces/IAvatar.sol";
import "./abstract/Opinions.sol";
// import "./abstract/ContractBase.sol";
import "./abstract/CommonYJUpgradable.sol";


/**
 * @title NFT Soulbound Identity Tokens
 * @dev Version 2.0
 *  - Contract is open for everyone to mint.
 *  - Max of one NFT assigned for each account
 *  - Can create un-assigned NFT (Kept on contract)
 *  - Minted Token's URI is updatable by Token holder
 *  - Assets are non-transferable by owner
 *  - Tokens can be merged (Multiple Owners)
 *  - [TODO] Orphan tokens can be claimed/linked
 */
contract SoulUpgradable is 
        IAvatar, 
        Initializable,
        // ContractBase,
        CommonYJUpgradable, 
        UUPSUpgradeable,
        Opinions,
        ERC721URIStorageUpgradeable {
        // ERC721URIStorage {
    
    //--- Storage
    
    using AddressUpgradeable for address;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIds;

    //Positive & Negative Reputation Tracking Per Domain (Personal,Community,Professional) 
    // mapping(uint256 => mapping(DataTypes.Domain => mapping(DataTypes.Rating => uint256))) internal _rep;  //[Token][Domain][bool] => Rep     //Inherited from Opinions
    mapping(address => uint256) internal _owners;  //Map Multiple Accounts to Tokens (Aliases)


    //--- Modifiers


    //--- Functions

    /// Initializer
    function initialize (address hub) public initializer {
        //Initializers
        __ERC721_init("Soulbound Tokens (YJ.life)", "SOUL");
        __ERC721URIStorage_init();
        __UUPSUpgradeable_init();
        __CommonYJ_init(hub);
        //Set Contract URI
        // _setContractURI(uri_);
    }

    /// Upgrade Permissions
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override { }

    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAvatar).interfaceId || super.supportsInterface(interfaceId);
    }

    //** Token Owner Index **/

    /// Map Account to Existing Token
    function tokenOwnerAdd(address owner, uint256 tokenId) external override onlyOwner {
        _tokenOwnerAdd(owner, tokenId);
    }

    /// Remove Account from Existing Token
    function tokenOwnerRemove(address owner, uint256 tokenId) external override onlyOwner {
        _tokenOwnerRemove(owner, tokenId);
    }

    /// Get Token ID by Address
    function tokenByAddress(address owner) external view override returns (uint256){
        return _owners[owner];
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return (_owners[owner] != 0) ? 1 : 0;
        // if(_owners[owner] != 0) return 1;
        // return super.balanceOf(owner);
    }

    /// Map Account to Existing Token (Alias / Secondary Account)
    function _tokenOwnerAdd(address owner, uint256 tokenId) internal {
        require(_exists(tokenId), "nonexistent token");
        require(_owners[owner] == 0, "Account already mapped to token");
        _owners[owner] = tokenId;
        //Faux Transfer Event (Mint)
        emit Transfer(address(0), owner, tokenId);
    }

    /// Map Account to Existing Token (Alias / Secondary Account)
    function _tokenOwnerRemove(address owner, uint256 tokenId) internal {
        require(_exists(tokenId), "nonexistent token");
        require(_owners[owner] == tokenId, "Account is not mapped to this token");
        //Not Main Account
        require(owner != ownerOf(tokenId), "Account is main token's owner. Use burn()");
        //Remove Association
        _owners[owner] = 0;
        //Faux Transfer Event (Burn)
        emit Transfer(owner, address(0), tokenId);
    }

    //** Reputation **/
    
    /// Add Reputation (Positive or Negative)
    function repAdd(uint256 tokenId, string calldata domain, bool rating, uint8 amount) external override {
        //Validate - Only By Hub
        require(_msgSender() == address(_HUB), "UNAUTHORIZED_ACCESS");
        //Set
        _repAdd(address(this), tokenId, domain, rating, amount);
    }
    
    //** Token Actions **/
    
    /// Mint (Create New Avatar for oneself)
    function mint(string memory tokenURI) public override returns (uint256) {
        //One Per Account
        require(balanceOf(_msgSender()) == 0, "Requesting account already has an avatar");
        //Mint
        uint256 tokenId = _createAvatar(_msgSender(), tokenURI);
        //Index Owner
        // _tokenOwnerAdd(_msgSender(), tokenId);   //MOVED TO TokenTransfer Logic
        //Return
        return tokenId;
    }
	
    /// Add (Create New Avatar Without an Owner)
    function add(string memory tokenURI) external override returns (uint256) {
        //Mint
        return _createAvatar(address(this), tokenURI);
    }

    /// Burn NFTs
    function burn(uint256 tokenId) external {
        //Validate Owner of Contract
        require(_msgSender() == owner(), "Only Owner");
        //Burn Token
        _burn(tokenId);
    }

    /// Update Token's Metadata
    function update(uint256 tokenId, string memory uri) public override returns (uint256) {
        //Validate Owner of Token
        require(_isApprovedOrOwner(_msgSender(), tokenId) || _msgSender() == owner(), "caller is not owner nor approved");
        _setTokenURI(tokenId, uri);	//This Goes for Specific Metadata Set (IPFS and Such)
        //Emit URI Changed Event
        emit URI(uri, tokenId);
        //Done
        return tokenId;
    }

    /// Create a new Avatar
    function _createAvatar(address to, string memory uri) internal returns (uint256){
        //Validate - Bot Protection
        require(tx.origin == _msgSender(), "Bots not allowed");
        //Mint
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(to, newItemId);
        //Set URI
        _setTokenURI(newItemId, uri);	//This Goes for Specific Metadata Set (IPFS and Such)
        //Emit URI Changed Event
        emit URI(uri, newItemId);
        //Done
        return newItemId;
    }
    
    /// Token Transfer Rules
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721Upgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
        //Can't be owned by a Contract
        require(to == address(this) || !to.isContract(), "Destination is a Contract");
        //Non-Transferable (by client)
        require(
            _msgSender() == owner()
            || from == address(0)   //Minting
            // || to == address(0)     //Burning
            ,
            "Sorry, Assets are non-transferable"
        );
        
        //Update Address Index        
        if(from != address(0)) _owners[from] = 0;
        if(to != address(0) && to != address(this)){
            require(_owners[to] == 0, "Receiving address already owns a token");
            _owners[to] = tokenId;
        }
    }
    // function _afterTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721) {
        // _owners[owner] = tokenId;
    // }

    /// Transfer Privileges are manged in the _beforeTokenTransfer function
    /// @dev Override the main Transfer privileges function
    function _isApprovedOrOwner(address, uint256) internal pure override returns (bool) {
        return true;
    }

    /// Receiver Function For Holding NFTs on Contract
    /// @dev needed in order to keep tokens in the contract
    function onERC721Received(address, address, uint256, bytes memory) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /* Try without it, since we don't want any regular ERC1155 to be received
    /// Receiver Function For Holding NFTs on Contract (Allow for internal NFTs to assume Roles)
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    /// Receiver Function For Holding NFTs on Contract
    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public pure returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
    */

}
