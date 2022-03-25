// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC1155GUID {
    //--- Functions 
    
   /// Assign Someone to a Role
    function roleAssign(address account, string calldata role) external;

    /// Remove Someone Else from a Role
    function roleRemove(address account, string calldata role) external;

    /// Check if account is assigned to role
    function roleHas(address account, string calldata role) external view returns (bool);
    
    /// Create a new Role
    // function roleCreate(address account, string calldata role) external;

    //--- Events
    
    event RoleCreated(uint256 indexed id, string role);        // Role Added Event? ... Transfer events should cover this...
    event CaseCreated(uint256 indexed id, address contractAddress);
}
