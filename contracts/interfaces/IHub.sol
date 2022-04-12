// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../libraries/DataTypes.sol";

interface IHub {
    
    //--- Functions

    /// Arbitrary contract designation signature
    function role() external view returns (string memory);
    
    /// Get Owner
    function owner() external view returns (address);
    
    /// Make a new Case
    // function caseMake(string calldata name_) external returns (address);
    // function caseMake(string calldata name_, DataTypes.RuleRef[] memory addRules) external returns (address);
    function caseMake(string calldata name_, DataTypes.RuleRef[] memory addRules, DataTypes.InputRole[] memory assignRoles) external returns (address);

    //--- Events

    /// Case Implementation Contract Updated
    event UpdatedCaseImplementation(address implementation);

}
