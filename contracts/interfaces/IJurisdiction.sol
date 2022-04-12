// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "../libraries/DataTypes.sol";

interface IJurisdiction {
    
    //--- Functions

    /// Symbol As Arbitrary contract designation signature
    function symbol() external view returns (string memory);

    /// Contract URI
    function contractURI() external view returns (string memory);

    /// Join jurisdiction as member
    function join() external;

    /// Leave member role in current jurisdiction
    function leave() external;

    /// Assign Someone to a Role
    function roleAssign(address account, string calldata role) external;

    /// Remove Someone Else from a Role
    function roleRemove(address account, string calldata role) external;
    
    /// Create a new Role
    // function roleCreate(address account, string calldata role) external;

    /// Make a new Case
    // function caseMake(
    //     string calldata name_, 
    //     DataTypes.RuleRef[] calldata addRules, 
    //     DataTypes.InputRole[] calldata assignRoles, 
    //     PostInput[] calldata posts
    // ) external returns (uint256, address);
    
    //-- Rule Func.

    /// Create New Rule
    function ruleAdd(DataTypes.Rule memory rule, DataTypes.Confirmation memory confirmation) external returns (uint256);

    /// Update Rule
    function ruleUpdate(uint256 id, DataTypes.Rule memory rule) external;
    

    //--- Events

    /// New Case Created
    event CaseCreated(uint256 indexed id, address contractAddress);    
}
