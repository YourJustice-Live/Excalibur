// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../libraries/DataTypes.sol";

interface IOpinions {
    
    //--- Functions

    /// Fetch Opinion (Crosschain)
    function getRepForDomain(uint256 chainId, address contractAddr, uint256 tokenId, string calldata domain, bool rating) external view returns (uint256);

    /// Fetch Opinion (Current Chain)
    function getRepForDomain(address contractAddr, uint256 tokenId, string calldata domain, bool rating) external view returns (uint256);

    /// Fetch Opinion (Self)
    function getRepForDomain(uint256 tokenId, string calldata domain, bool rating) external view returns (uint256);

    //--- Events

    /// Opinion Changed
    // event OpinionChange(address indexed contractAddr, uint256 indexed tokenId, string domain, DataTypes.Rating rating, uint256 score);

    /// Opinion Changed (Crosschain)
    event OpinionChange(uint256 chainId, address indexed contractAddr, uint256 indexed tokenId, string domain, bool rating, uint256 score);

}
