//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * Common Protocol Functions
 */
interface ICommonYJ {
    
    /// Inherit owner from Protocol's config
    function owner() external view returns (address);
    
}
