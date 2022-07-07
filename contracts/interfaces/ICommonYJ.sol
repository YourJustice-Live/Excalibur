//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

/**
 * Common Protocol Functions
 */
interface ICommonYJ {
    
    /// Inherit owner from Protocol's config
    function owner() external view returns (address);
    
    // Change Hub (Move To a New Hub)
    function setHub(address hubAddr) external;

    /// Get Hub Contract
    function getHub() external view returns(address);
    
    //Repo Address
    function repoAddr() external view returns(address);

    /// Generic Config Get Function
    // function confGet(string memory key) external view returns(string memory);

    /// Generic Config Set Function
    // function confSet(string memory key, string memory value) external;

    //-- Events

}
