//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../interfaces/ISoul.sol";

/**
 * @title Tracker Contract Functions
 * @dev To Extend Contracts with Token Tracking Funtionality
 */
abstract contract TrackerUpgradable {
    
    // Target Contract (External Source)
    address _targetContract;

    /// Get Target Contract
    // function getTargetContract() public view virtual returns (address) {
    //     return _targetContract;
    // }

    /// Set Target Contract
    function __setTargetContract(address targetContract) internal virtual {
        //Validate Interfaces
        // require(IERC165(targetContract).supportsInterface(type(IERC721).interfaceId), "Target Expected to Support IERC721"); //Additional 0.238Kb
        require(IERC165(targetContract).supportsInterface(type(ISoul).interfaceId), "Target contract expected to support ISoul");
        _targetContract = targetContract;
    }

    /// Get a Token ID Based on account address (Throws)
    function getExtTokenId(address account) public view returns(uint256) {
        //Validate Input
        require(account != _targetContract, "ERC1155Tracker: source contract address is not a valid account");
        //Get
        uint256 ownerToken = _getExtTokenId(account);
        //Validate Output
        require(ownerToken != 0, "ERC1155Tracker: requested account not found on source contract");
        //Return
        return ownerToken;
    }

    /// Get a Token ID Based on account address
    function _getExtTokenId(address account) internal view returns (uint256) {
        // require(account != address(0), "ERC1155Tracker: address zero is not a valid account");       //Redundant 
        require(account != _targetContract, "ERC1155Tracker: source contract address is not a valid account");
        //Run function on destination contract
        // return ISoul(_targetContract).tokenByAddress(account);
        uint256 ownerToken = ISoul(_targetContract).tokenByAddress(account);
        //Validate
        // require(ownerToken != 0, "ERC1155Tracker: account not found on source contract");
        //Return
        return ownerToken;
    }
    
}
