// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../libraries/DataTypes.sol";

interface IActionRepo {
    /// Symbol As Arbitrary contract designation signature
    function symbol() external view returns (string memory);
    /// Get Owner
    // function owner() external view returns (address);


    /// Set Action's Metadata URI
    function actionSetURI(bytes32 guid, string memory uri) external;

    /// Get Action by GUID
    function actionGet(bytes32 guid) external view returns (DataTypes.SVO memory);

    /// Set Action's Data
    function actionSetData(bytes32 guid, DataTypes.RoleData memory data) external;

    /// Store 

    //--- Events
    /// Action Added
    event ActionAdded(bytes32 indexed id, string subject, string verb, string object, string tool, string affected);
    /// Action Removed
    // event ActionRemoved(bytes32 indexed id);

}
