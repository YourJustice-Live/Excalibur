//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/governance/utils/IVotes.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
// import "../interfaces/IVotes.sol";

/**
 * @title Voting power tracking
 * @dev Votes Repository -- Retains Voting power information for other Contracts
 * Version 1.0
 * - DOES WHAT?
 * - Owned by Requesting Address
 */
abstract    //TODO: REMOVE THIS
contract VotesRepo is IVotes, ERC165 {

    //--- Storage
    
    //Arbitrary Contract Name & Symbol 
    string public constant symbol = "VOTES";
    string public constant name = "Voting Power Repository";
    
    
    //--- Functions

    // constructor() { }

    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IVotes).interfaceId 
            || super.supportsInterface(interfaceId);
    }



}