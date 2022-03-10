// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";		//https://eips.ethereum.org/EIPS/eip-721
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";  //Individual Metadata URI Storage Functions
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//Interfaces
import "./interfaces/IConfig.sol";


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

    address private _CONFIG;    //Configuration Contract

    /**
	 * Constructor
	 */
    constructor(address config) ERC721("Avatar", "AVATAR") {
        //Set Protocol's Config Address
        _CONFIG = config;
    }

    /**
     * Get Configurations Contract Address
     */
    function getConfig() public view returns (address) {
        return _CONFIG;
    }

    /**
     * Set Configurations Contract Address
     */
    function setConfig(address config) public onlyOwner {
        //Validate Contract's Designation
        require(keccak256(abi.encodePacked(IConfig(config).role())) == keccak256(abi.encodePacked("YJConfig")), "Invalid Config Contract");
        //Set
        _CONFIG = config;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view override returns (address) {
        return IConfig(getConfig()).owner();
    }

    /**
     * @dev Transfer Rules
     */
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
    
}
