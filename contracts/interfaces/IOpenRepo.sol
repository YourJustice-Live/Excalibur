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
    function addressSet(string memory key, address destinationContract) external;

    /// Add Address to Slot
    function addressAdd(string memory key, address destinationContract) external;

    /// Remove Address from Slot
    function addressRemove(string memory key, address destinationContract) external;


    //--- Events

    /// Association Set
    event AddressSet(address originContract, string key, address destinationContract);

    /// Association Added
    event AddressAdd(address originContract, string key, address destinationContract);

    /// Association Added
    event AddressRemoved(address originContract, string key, address destinationContract);

}
