// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";		//https://eips.ethereum.org/EIPS/eip-721
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";  //Individual Metadata URI Storage Functions
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/**
 * Avatar as NFT
 * Version 0.0.1
 *  - [TODO] Contract is open for everyone to mint.
 *  - [TODO] Minted Tokens are updatable by Token holder
 *  - [TODO] Assets are non-transferable by owner
 *  - [TODO] Max of one NFT for account
 *  - [TODO] Contract is Updatable
 */
contract AvatarNFT is ERC721URIStorage, Ownable {

    /**
	 * Constructor
	 */
    constructor() ERC721("Avatar", "AVATAR") {

    }
    
}
