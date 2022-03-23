// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IActionRepo {
    /// Symbol As Arbitrary contract designation signature
    function symbol() external view returns (string memory);
    /// Get Owner
    // function owner() external view returns (address);

    
    //--- Events
    /// Action Added
    event ActionAdded(bytes32 indexed id, string subject, string verb, string object, string tool, string affected);
    /// Action Removed
    // event ActionRemoved(bytes32 indexed id);

}
