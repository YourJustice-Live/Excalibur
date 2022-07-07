// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// import "../public/interfaces/IOpenRepo.sol";
import "../interfaces/IGameUp.sol";

/**
 * @title GameExtension
 */
abstract contract GameExtension {

    //--- Storage
    
    //--- Functions 

    //Use Self (Main Game)
    function _game() internal view returns (IGame) {
        return IGame(address(this));
    }
    
}
