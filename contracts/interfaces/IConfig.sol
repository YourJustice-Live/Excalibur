// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IConfig {
    
    //-- Functions

    /// Arbitrary contract designation signature
    function symbol() external view returns (string memory);
    /// Get Owner
    function owner() external view returns (address);
    /// Set Treasury Address
    function setTreasury(address newTreasury) external;
    
}
