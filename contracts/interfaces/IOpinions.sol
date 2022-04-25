// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../libraries/DataTypes.sol";

interface IOpinions {
    
    //--- Functions

    /// Fetch Opinion 
    function getRepForDomain(address contractAddr, uint256 tokenId, DataTypes.Domain domain, DataTypes.Rating rating) external view returns (uint256);

    /// Fetch Opinion (Multichain)
    function getRepForDomain(uint256 chainId, address contractAddr, uint256 tokenId, DataTypes.Domain domain, DataTypes.Rating rating) external view returns (uint256);

    //--- Events

    /// Opinion Changed
    event OpinionChange(address indexed contractAddr, uint256 indexed tokenId, DataTypes.Domain domain, DataTypes.Rating rating, uint256 score);

}
