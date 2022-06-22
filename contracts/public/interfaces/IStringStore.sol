// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IStringStore {

    //--- Functions

    /// Get Association
    function stringGet(string memory key) external view returns(string memory);

    /// Get Contract Association
    function stringGetOf(address originAddress, string memory key) external view returns(string memory);

    /// Get First Address in Index
    function stringGetIndexOf(address originAddress, string memory key, uint256 index) external view returns(string memory);

    /// Get First Address in Index
    function stringGetIndex(string memory key, uint256 index) external view returns(string memory);

    /// Set  Association
    function stringSet(string memory key, string memory value) external;

    /// Add Address to Slot
    function stringAdd(string memory key, string memory value) external;

    /// Remove Address from Slot
    function stringRemove(string memory key, string memory value) external;

}
