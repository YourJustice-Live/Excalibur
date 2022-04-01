// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IJurisdiction {
    /// Symbol As Arbitrary contract designation signature
    function symbol() external view returns (string memory);

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

    //--- Events
    
}
