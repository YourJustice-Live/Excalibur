// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IVotesRepo {

    //--- Functions
    
    /// Expose Voting Power Transfer Method
    function transferVotingUnits(address from, address to, uint256 amount) external;

}
