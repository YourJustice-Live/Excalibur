// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "../libraries/DataTypes.sol";

interface IRecursion {
    
    //--- Functions

    /// Check if a Contract Address is a an Immediate Parent of Current Contract
    function isParent(address contractAddr) external view returns (bool);
    
    /// Check if a Contract Address is a Parent of Current Contract (Recursive)
    function isParentRec(address contractAddr) external view returns (bool);

    //--- Events

    /// Parent Added
    event ParentAdded(address contractAddr);

    /// Parent Removed
    event ParentRemoved(address contractAddr);

}
