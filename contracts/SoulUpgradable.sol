// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";

// import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "./interfaces/ISoul.sol";
import "./abstract/Opinions.sol";
import "./abstract/ProtocolEntityUpgradable.sol";


/**
 * @title Soulbound NFT Identity Tokens + Reputation Tracking
 * @dev Version 2.1
 *  - Contract is open for everyone to mint.
 *  - Max of one NFT assigned for each account
 *  - Can create un-assigned NFT (Kept on contract)
 *  - Minted Token's URI is updatable by Token holder
 *  - Assets are non-transferable by owner
 *  - Tokens can be merged (multiple owners)
 *  - Owner can mint tokens for Contracts
 *  - [TODO] Orphan tokens can be claimed/linked
 */
contract SoulUpgradable is 
        ISoul, 
        Initializable,
        ProtocolEntityUpgradable, 
        UUPSUpgradeable,
        Opinions,
        ERC721URIStorageUpgradeable {
        // ERC721URIStorage {
    
    //--- Storage
    
    using AddressUpgradeable for address;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIds;

    mapping(address => uint256) internal _owners;  //Map Multiple Accounts to Tokens (Aliases)
    mapping(uint256 => string) public types;    //Soul Types
    mapping(uint256 => address) internal _link; //[TBD] Linked Souls

    //--- Modifiers


    //--- Functions

    /// Initializer
    function initialize (address hub) public initializer {
        //Initializers
        __ERC721_init("Soulbound Tokens (YJ.life)", "SOUL");
        __ERC721URIStorage_init();
        __UUPSUpgradeable_init();
        __ProtocolEntity_init(hub);
        //Set Contract URI
        // _setContractURI(uri_);
    }

    /// Upgrade Permissions
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override { }

    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ISoul).interfaceId
            || interfaceId == type(IERC721Upgradeable).interfaceId 
            || super.supportsInterface(interfaceId);
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
    
    /// Mint (Create New Token for Someone Else)
    function mintFor(address to, string memory tokenURI) public override returns (uint256) {
        //Validate - Contract Owner 
        // require(_msgSender() == owner(), "Only Owner");
        require(_msgSender() == owner() || _msgSender() == address(_HUB), "Only Owner or Hub");
        //Mint
        return _mint(to, tokenURI);
    }

    /// Mint (Create New Token for oneself)
    function mint(string memory tokenURI) external override returns (uint256) {
        //Mint
        return _mint(_msgSender(), tokenURI);
    }
	
    /// Add (Create New Token Without an Owner)
    function add(string memory tokenURI) external override returns (uint256) {
        //Mint
        return _mint(address(this), tokenURI);
    }

    /// Burn NFTs
    function burn(uint256 tokenId) external {
        //Validate - Contract Owner 
        require(_msgSender() == owner(), "Only Owner");
        //Burn Token
        _burn(tokenId);
    }

    /// Update Token's Metadata
    function update(uint256 tokenId, string memory uri) external override returns (uint256) {
        //Validate Owner of Token
        require(_isApprovedOrOwner(_msgSender(), tokenId) || _msgSender() == owner(), "caller is not owner nor approved");
        _setTokenURI(tokenId, uri);	//This Goes for Specific Metadata Set (IPFS and Such)
        //Emit URI Changed Event
        emit URI(uri, tokenId);
        //Done
        return tokenId;
    }

    /// Create a new Token
    function _mint(address to, string memory uri) internal returns (uint256){
        //Validate - Bot Protection
        // require(tx.origin == _msgSender(), "Bots not allowed");      //CANCELLED - Allow Contracts to Have Souls
        //One Per Account
        require(to == address(this) || balanceOf(_msgSender()) == 0, "Requesting account already has a token");
        //Mint
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(to, newItemId);
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
        //Can't be owned by a Contract      //CANCELLED - Allow Contracts to have Souls
        // require(to == address(this) || !to.isContract(), "Destination is a Contract");

        //Non-Transferable (by client)
        require(
            _msgSender() == owner()
            || from == address(0)   //Minting
            , "Sorry, assets are non-transferable"
        );
        
        //Update Address Index        
        if(from != address(0)) _owners[from] = 0;
        if(to != address(0) && to != address(this)){
            require(_owners[to] == 0, "Receiving address already owns a token");
            _owners[to] = tokenId;
        }
    }

    /// Hook - After Token Transfer
    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        //Soul Type
        string memory soulType = _getType(to);
        //Set
        types[tokenId] = soulType;
        //Emit Soul Type as Event
        emit SoulType(tokenId, soulType);
    }

    /// Get Owner Type
    function _getType(address account) private view returns(string memory){
        
        // console.log("** _getType() Return: ", response);

        if (account.isContract() && account != address(this)) {

            // console.log("THIS IS A Contract:", account);

            try IToken(account).symbol() returns (string memory response) {

                // console.log("* * * Contract Symbol:", account, response);

                //Contract's Symbol
                return response;
            } catch {
                //Unrecognized Contract
                return "CONTRACT";
            }
        }
        // console.log("THIS IS NOT A Contract:", account);
        //Not a contract
        return "";
    } 

    /// Transfer Privileges are manged in the _beforeTokenTransfer function
    /// @dev Override the main Transfer privileges function
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view override returns (bool) {
        //Approved or Seconday Owner
        return (super._isApprovedOrOwner(spender, tokenId)  || (_owners[spender] == tokenId));
    }

    /// Override transferFrom()
    /// Remove Approval Check 
    /// Transfer Privileges are manged in the _beforeTokenTransfer function
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        // require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _transfer(from, to, tokenId);
    }

    /// Check if the Current Account has Control over a Token
    function hasTokenControl(uint256 tokenId) public view override returns (bool) {
        address ownerAccount = ownerOf(tokenId);
        return (
            // ownerAccount == _msgSender()    //Token Owner
            // solhint-disable-next-line avoid-tx-origin
            ownerAccount == tx.origin    //Token Owner (Allows it to go therough the hub)
            // solhint-disable-next-line avoid-tx-origin
            || (ownerAccount == address(this) && owner() == tx.origin) //Unclaimed Tokens Controlled by Contract Owner/DAO
        );
    }

    /// Post
    function post(uint256 tokenId, string calldata uri_) external override {
        //Validate that User Controls The Token
        require(hasTokenControl(tokenId), "SOUL:NOT_YOURS");
        //Post Event
        emit Post(_msgSender(), tokenId, uri_);
    }

}

/// Generic Interface used to get Symbol
interface IToken {
    /// Arbitrary contract symbol
    function symbol() external view returns (string memory);
}
