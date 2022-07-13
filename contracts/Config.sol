//SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
// import "./interfaces/IConfig.sol";

/** DEPRECATE
 * Global Configuration Contract
 * - He who owns the config owns the protocol
 */
contract Config is Ownable {
// contract Config is IConfig, Ownable {

    //-- Storage
    
    // Symbol as Arbitrary contract designation signature
    string public constant symbol = "Config";
    
    //Treasury
    address private _treasury;

    //-- Events

    event TreasurySet(address treasury);

    //-- Functions 
        
    /// Set Treasury Address
    function setTreasury(address newTreasury) public onlyOwner {
        require(newTreasury != address(0), "ZERO_ADDRESS");
        _treasury = newTreasury;
        emit TreasurySet(newTreasury);
    }

}
