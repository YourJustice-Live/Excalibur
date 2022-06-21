// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../libraries/DataTypes.sol";

interface IHub {
    
    //--- Functions

    /// Arbitrary contract symbol
    function symbol() external view returns (string memory);
    
    /// Arbitrary contract designation signature
    function role() external view returns (string memory);
    
    /// Get Owner
    function owner() external view returns (address);

    //Repo Address
    function repoAddr() external view returns(address);

    /// Make a new Jurisdiction
    function jurisdictionMake(string calldata name_, string calldata uri_) external returns (address);

    /// Make a new Case
    // function caseMake(string calldata name_, DataTypes.RuleRef[] memory addRules, DataTypes.InputRole[] memory assignRoles) external returns (address);
    function caseMake(
        string calldata name_, 
        string calldata uri_, 
        DataTypes.RuleRef[] memory addRules, 
        DataTypes.InputRoleToken[] memory assignRoles
    ) external returns (address);

    /// Update Hub
    function hubChange(address newHubAddr) external;

    //Get Avatar Contract Address
    // function avatarContract() external view returns (address);

    //Get History Contract Address
    // function historyContract() external view returns (address);

    /// Add Reputation (Positive or Negative)       /// Opinion Updated
    function repAdd(address contractAddr, uint256 tokenId, string calldata domain, bool rating, uint8 amount) external;

    /* MOVED to IAssoc
    //Get Contract Association
    function getAssoc(string memory key) external view returns(address);
    */
    
    //--- Events

    /// Beacon Contract Chnaged
    event UpdatedImplementation(string name, address implementation);

    /// New Contract Created
    event ContractCreated(string name, address contractAddress);

    /// New Contract Created
    event HubChanged(address contractAddress);

}
