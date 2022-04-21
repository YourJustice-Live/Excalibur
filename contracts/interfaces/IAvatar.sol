// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "../libraries/DataTypes.sol";

interface IAvatar {

    //--- Functions

    /// Arbitrary contract designation signature
    // function role() external view returns (string memory);

    /// Mint (Create New Avatar for oneself)
    function mint(string memory tokenURI) external returns (uint256);

    /// Add (Create New Avatar Without an Owner)
    function add(string memory tokenURI) external returns (uint256);

    /// Update Token's Metadata
    function update(uint256 tokenId, string memory uri) external returns (uint256);

    /// Add Reputation (Positive or Negative)
    function repAdd(uint256 tokenId, DataTypes.Domain domain, DataTypes.Rating rating, uint8 amount) external;

    //--- Events
    
	/// URI Change Event
    event URI(string value, uint256 indexed id);    //Copied from ERC1155

    /// Reputation Changed
    event ReputationChange(uint256 indexed id, DataTypes.Domain domain, DataTypes.Rating rating, uint256 score);

}
