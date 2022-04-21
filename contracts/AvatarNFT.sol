// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";		//https://eips.ethereum.org/EIPS/eip-721
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";  //Individual Metadata URI Storage Functions
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";  //To Hold NFTs on Contract
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "./interfaces/IConfig.sol";
import "./interfaces/IAvatar.sol";
import "./libraries/DataTypes.sol";
import "./abstract/CommonYJ.sol";

/**
 * @title Avatar as NFT
 * @dev Version 0.3.0
 *  - Contract is open for everyone to mint.
 *  - Max of one NFT assigned for each account
 *  - Can create un-assigned NFT (Kept on contract)
 *  - Minted Token's URI is updatable by Token holder
 *  - Assets are non-transferable by owner
 *  - Tokens can be merged (Multiple Owners)
 *  - [TODO] Orphan tokens can be claimed
 *  - [TODO] Contract is Updatable
  */
contract AvatarNFT is IAvatar, CommonYJ, ERC721URIStorage, IERC721Receiver {
    
    //--- Storage
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //Positive & Negative Reputation Tracking Per Domain (Personal,Community,Professional) 
    mapping(uint256 => mapping(DataTypes.Domain => mapping(DataTypes.Rating => uint256))) internal _rep;  //[Token][Domain][bool] => Rep
    mapping(address => uint256) internal _owners;  //Map Accounts to Tokens


    //--- Modifiers


    //--- Functions

    /// Constructor
    constructor(address hub) CommonYJ(hub) ERC721("Avatar", "AVATAR") {

    }

    //** Token Owner Index **/

    /// Map Account to Existing Token
    function tokenOwnerAdd(address owner, uint256 tokenId) external onlyOwner {
        _tokenOwnerAdd(owner, tokenId);
    }

    /// Get Token ID by Address
    function tokenByAddress(address owner) external view override returns (uint256){
        return _owners[owner];
    }

    /// Map Account to Existing Token
    function _tokenOwnerAdd(address owner, uint256 tokenId) internal {
        require(_exists(tokenId), "nonexistent token");
        require(_owners[owner] == 0, "Account Already Mapped to Token");
        _owners[owner] = tokenId;
    }

    //** Reputation **/
    
    /// Add Reputation (Positive or Negative)
    function repAdd(uint256 tokenId, DataTypes.Domain domain, DataTypes.Rating rating, uint8 amount) external override {
        //Validate
        require(_msgSender() == address(_HUB), "UNAUTHORIZED_ACCESS");
        //Set
        _rep[tokenId][domain][rating] += amount;
        //Event
        emit ReputationChange(tokenId, domain, rating, _rep[tokenId][domain][rating]);
    }

    /// Fetch Avatar's Reputation 
    function getRepForDomain(uint256 tokenId, DataTypes.Domain domain, DataTypes.Rating rating) public view returns (uint256){
        return _rep[tokenId][domain][rating];
    }
    
    //** Token Actions **/
    
    /// Mint (Create New Avatar for oneself)
    function mint(string memory tokenURI) public override returns (uint256) {
        //One Per Account
        require(balanceOf(_msgSender()) == 0, "Requesting account already has an avatar");
        
        //Mint
        uint256 tokenId = _createAvatar(_msgSender(), tokenURI);
        //Index Owner
        _tokenOwnerAdd(_msgSender(), tokenId);
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
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721) {
        super._beforeTokenTransfer(from, to, tokenId);
        require(
            _msgSender() == owner()
            || from == address(0)   //Minting
            // || to == address(0)     //Burning
            ,
            "Sorry, Assets are non-transferable"
        );
    }

    /// For Holding NFTs on Contract
    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
    // function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

}
