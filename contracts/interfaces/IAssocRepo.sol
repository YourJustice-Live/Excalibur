// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IAssocRepo {
    
    //--- Functions

    /// Set  Association
    function setAssoc(string memory key, address destinationContract) external;

    /// Get Association
    function getAssoc(string memory key) external view returns(address);

    /// Get Contract Association
    function getAssocOf(address originContract, string memory key) external view returns(address);

    //--- Events

    /// Association Set
    event Assoc(address originContract, string key, address destinationContract);

}
