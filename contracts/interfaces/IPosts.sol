// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "../libraries/DataTypes.sol";

interface IPosts {


    //--- Functions


    //--- Events

    /// General Post / Evidence, etc'
    // event Post(address indexed account, string entRole, string postRole, string uri);        //postRole Moved to uri
    event Post(address indexed account, string entRole, string uri);


}
