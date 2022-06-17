// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IOpenRepo {

    //--- Functions

    /// Get Association
    function addressGet(string memory key) external view returns(address);

    /// Get Contract Association
    function addressGetOf(address originContract, string memory key) external view returns(address);

    /// Get First Address in Index
    function addressGetIndexOf(address originContract, string memory key, uint256 index) external view returns(address);

    /// Get First Address in Index
    function addressGetIndex(string memory key, uint256 index) external view returns(address);

    /// Set  Association
    function addressSet(string memory key, address value) external;

    /// Add Address to Slot
    function addressAdd(string memory key, address value) external;

    /// Remove Address from Slot
    function addressRemove(string memory key, address value) external;


    //--- Events

    /// Association Set
    event AddressSet(address originAddress, string key, address destinationAddress);

    /// Association Added
    event AddressAdd(address originAddress, string key, address destinationAddress);

    /// Association Added
    event AddressRemoved(address originAddress, string key, address destinationAddress);

}
