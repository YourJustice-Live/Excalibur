// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity 0.8.4;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IERC1155RolesTracker {

    //--- Functions

    /// Unique Members Addresses
    function uniqueRoleMembers(string memory role) external view returns (uint256[] memory);

    /// Unique Members Count (w/Token)
    function uniqueRoleMembersCount(string memory role) external view returns (uint256);    

    /// Check if Role Exists
    function roleExist(string memory role) external view returns (bool);

    /// Check if account is assigned to role
    function roleHas(address account, string calldata role) external view returns (bool);

    /// Check if Soul Token is assigned to role
    function roleHasByToken(uint256 soulToken, string memory role) external view returns (bool);

    /// Get Metadata URI by Role
    function roleURI(string calldata role) external view returns(string memory);

    //--- Events

    /// New Role Created
    event RoleCreated(uint256 indexed id, string role);

    /// URI Change Event
    event RoleURIChange(string value, string role);
}