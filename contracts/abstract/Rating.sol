//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "../libraries/DataTypes.sol";
import "../interfaces/IRating.sol";

/**
 * @title Rating for Contracts & Tokens
 * @dev Designed To Be Used by Jurisdictions
 * - Hold & Update Multidimentional Rating Data
 */
contract Rating is IRating {
    
    // Reputation Tracking - Positive & Negative Reputation Tracking Per Domain (Environmantal, Personal, Community, Professional) For Tokens in Contracts
    
    // mapping(address => mapping(uint256 => mapping(DataTypes.Domain => mapping(DataTypes.Rating => uint256)))) internal _rep;
    // [Contract][Token] => [Domain][Rating] => uint

    mapping(uint256 => mapping(address => mapping(uint256 => mapping(DataTypes.Domain => mapping(DataTypes.Rating => uint256))))) internal _rep;
    // [Chain][Contract][Token] => [Domain][Rating] => uint     //Crosschain Support

    /// Fetch Reputation 
    function getRepForDomain(address contractAddr, uint256 tokenId, DataTypes.Domain domain, DataTypes.Rating rating) public view override returns (uint256){
        return _rep[block.chainid][contractAddr][tokenId][domain][rating];
    }
    
    /// Add Reputation (Positive or Negative)
    function _repAdd(address contractAddr, uint256 tokenId, DataTypes.Domain domain, DataTypes.Rating rating, uint8 score) internal {
        //Update Reputation
        _rep[block.chainid][contractAddr][tokenId][domain][rating] += score;
        //Reputation Change Event
        emit ReputationChange(contractAddr, tokenId, domain, rating, score);
    }



}
