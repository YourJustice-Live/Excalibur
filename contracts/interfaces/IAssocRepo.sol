// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IAssocRepo {
    
    //--- Functions

    /// Set  Association
    function set(string memory key, address destinationContract) external;

    /// Get Association
    function get(string memory key) external view returns(address);

    /// Get Contract Association
    function getOf(address originContract, string memory key) external view returns(address);

    //--- Events

    /// Association Set
    event Assoc(address originContract, string key, address destinationContract);

}
