//SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * Global Configuration Contract
 * - He who owns the config owns the protocol
 */
contract Config is Ownable {

    // Arbitrary contract designation signature
    string public constant role = "YJConfig";
    
    
    // constructor() {
    
    // }
}
