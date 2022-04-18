// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../libraries/DataTypes.sol";

interface IRating {
    
    //--- Functions

    /// Fetch Reputation 
    function getRepForDomain(address contractAddr, uint256 tokenId, DataTypes.Domain domain, DataTypes.Rating rating) external view returns (uint256);

    //--- Events

    /// Reputation Changed
    event ReputationChange(address indexed contractAddr, uint256 indexed tokenId, DataTypes.Domain domain, DataTypes.Rating rating, uint256 score);

    
}
