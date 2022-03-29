// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../libraries/DataTypes.sol";

interface IActionRepo {
    /// Symbol As Arbitrary contract designation signature
    function symbol() external view returns (string memory);
    /// Get Owner
    // function owner() external view returns (address);

    /// Generate a Unique Hash for Event
    function actionHash(DataTypes.SVO memory svo) external pure returns (bytes32);

    /// Register New Action
    // function actionAdd(DataTypes.SVO memory svo) external returns (bytes32);
    function actionAdd(DataTypes.SVO memory svo, DataTypes.Confirmation memory confirmation, string memory uri) external returns (bytes32);
    
    /// Update URI for Action
    function actionSetURI(bytes32 guid, string memory uri) external;

    /// Update Confirmation Methof for Action
    function actionSetConfirmation(bytes32 guid, DataTypes.Confirmation memory confirmation) external;

    /// Get Action by GUID
    function actionGet(bytes32 guid) external view returns (DataTypes.SVO memory);

    /// Set Action's Data
    // function actionSetData(bytes32 guid, DataTypes.RoleData memory data) external;

    /// Store 

    //--- Events
    /// Action Added
    event ActionAdded(uint256 indexed id, bytes32 indexed guid, string subject, string verb, string object, string tool, string affected);
    /// Action Removed (No such thing)
    // event ActionRemoved(bytes32 indexed id);
    /// Action URI Updated
    event URI(bytes32 indexed guid, string uri);
    /// Action URI Updated
    event Confirmation(bytes32 indexed guid, DataTypes.Confirmation confirmation);      //[TEST] Is it right to emit structs in events?
}
