// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IBoolStore {

    //--- Functions

    /// Get Association
    function boolGet(string memory key) external view returns(bool);

    /// Get Contract Association
    function boolGetOf(address originContract, string memory key) external view returns(bool);

    /// Get First Address in Index
    function boolGetIndexOf(address originContract, string memory key, uint256 index) external view returns(bool);

    /// Get First Address in Index
    function boolGetIndex(string memory key, uint256 index) external view returns(bool);

    /// Set  Association
    function boolSet(string memory key, bool value) external;

    /// Add Address to Slot
    function boolAdd(string memory key, bool value) external;

    /// Remove Address from Slot
    function boolRemove(string memory key, bool value) external;

}
