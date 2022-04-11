// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";		//https://eips.ethereum.org/EIPS/eip-721
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";  //Individual Metadata URI Storage Functions
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";  //To Hold NFTs on Contract
// import "@openzeppelin/contracts/access/Ownable.sol";
//Interfaces
// import "./interfaces/IConfig.sol";
// import "./interfaces/IHub.sol";
//Libraries
import "./libraries/DataTypes.sol";
//Abstract
import "./abstract/CommonYJ.sol";

/**
 * @title Avatar as NFT
 * @dev Version 0.2.0
 *  - Contract is open for everyone to mint.
 *  - Max of one NFT assigned for each account
 *  - Can create un-assigned NFT (Kept on contract)
 *  - Minted Token's URI is updatable by Token holder
 *  - Assets are non-transferable by owner
 *  - [TODO] Orphan tokens can be claimed
 *  - [TODO] Contract is Updatable
  */
contract AvatarNFT is CommonYJ, ERC721URIStorage, IERC721Receiver {
    
    
    //--- Storage
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;


    //Positive & Negative Reputation Trackin Per Domain (Personal,Community,Professional) 
    mapping(uint256 => mapping(DataTypes.Domain => mapping(DataTypes.Rating => uint256))) internal _rep;  //[Token][Domain][bool] => Rep


    //--- Events
    
	/// URI Change Event
    event URI(string value, uint256 indexed id);    //Copied from ERC1155

    /// Reputation Changed
    event ReputationChange(uint256 indexed id, DataTypes.Domain domain, DataTypes.Rating rating, uint256 score);


    //--- Modifiers


    //--- Functions

    /// Constructor
    constructor(address hub) CommonYJ(hub) ERC721("Avatar", "AVATAR") {

    }

    /// Add Reputation (Positive or Negative)
    function repAdd(uint256 tokenId, DataTypes.Domain domain, DataTypes.Rating rating, uint8 amount) external {
        //[TBD] Validate

        //Set
        _rep[tokenId][domain][rating] += amount;
        //Event
        emit ReputationChange(tokenId, domain, rating, _rep[tokenId][domain][rating]);
    }

    /// Fetch Avatar's Reputation 
    function getRepForDomain(uint256 tokenId, DataTypes.Domain domain, DataTypes.Rating rating) public view returns (uint256){
        return _rep[tokenId][domain][rating];
    }
    
    /// Mint (Create New Avatar for oneself)
    function mint(string memory tokenURI) public returns (uint256) {
        //One Per Account
        require(balanceOf(_msgSender()) == 0, "Requesting account already has an avatar");
        //Mint
        return _createAvatar(_msgSender(), tokenURI);
    }
	
    /// Add (Create New Avatar Without an Owner)
    function add(string memory tokenURI) public returns (uint256) {
        //Mint
        return _createAvatar(address(this), tokenURI);
    }

    /// [TBD] Merge NFTs

    /// Burn NFTs
    function burn(uint256 tokenId) external {
        //Validate Owner of Contract
        require(_msgSender() == owner(), "Only Owner");
        //Burn Token
        _burn(tokenId);
    }

    /// Create a new Avatar
    function _createAvatar(address to, string memory uri) internal returns (uint256){
        //Validate - Bot Protection
        require(tx.origin == _msgSender(), "Bots not allowed");
        //Mint
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(to, newItemId);       //Self Only
        //Set URI
        _setTokenURI(newItemId, uri);	//This Goes for Specific Metadata Set (IPFS and Such)
        //Emit URI Changed Event
        emit URI(uri, newItemId);
        //Done
        return newItemId;
    }
    
    /// Update Token's Metadata
    function update(uint256 tokenId, string memory uri) public returns (uint256) {
        //Validate Owner of Token
        require(_isApprovedOrOwner(_msgSender(), tokenId) || _msgSender() == owner(), "caller is not owner nor approved");
        _setTokenURI(tokenId, uri);	//This Goes for Specific Metadata Set (IPFS and Such)
        //Emit URI Changed Event
        emit URI(uri, tokenId);
        //Done
        return tokenId;
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
