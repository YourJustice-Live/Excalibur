// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

/** DEPRECATE
 * Central Protocol Configuration
 */
interface IConfig {
    
    //-- Functions

    /// Arbitrary contract designation signature
    function symbol() external view returns (string memory);
    /// Get Owner
    function owner() external view returns (address);
    /// Set Treasury Address
    function setTreasury(address newTreasury) external;
    
}
