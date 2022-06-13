// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IOpenRepo {

    //--- Functions

    /// Set  Association
    function setAddress(string memory key, address destinationContract) external;

    /// Get Association
    function getAddress(string memory key) external view returns(address);

    /// Get Contract Association
    function getAddressOf(address originContract, string memory key) external view returns(address);

    //--- Events

    /// Association Set
    event AddressSet(address originContract, string key, address destinationContract);

}
