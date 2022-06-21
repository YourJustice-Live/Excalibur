// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IOpenRepo {

    //--- Functions

    //-- Addresses  

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

    //-- Booleans

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


    //-- Strings

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


    //--- Events

    //-- Addresses

    /// Association Set
    event AddressSet(address originAddress, string key, address destinationAddress);

    /// Association Added
    event AddressAdd(address originAddress, string key, address destinationAddress);

    /// Association Added
    event AddressRemoved(address originAddress, string key, address destinationAddress);


    //-- Booleans

    /// Association Set
    event BoolSet(address originContract, string key, bool value);

    /// Association Added
    event BoolAdd(address originContract, string key, bool value);

    /// Association Added
    event BoolRemoved(address originContract, string key, bool value);


    //-- Strings

    /// Association Set
    event StringSet(address originAddress, string key, string value);

    /// Association Added
    event StringAdd(address originAddress, string key, string value);

    /// Association Added
    event StringRemoved(address originAddress, string key, string value);


}
