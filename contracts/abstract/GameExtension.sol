// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";
import "../public/interfaces/IOpenRepo.sol";
import "../interfaces/ICommonYJ.sol";
import "../interfaces/IGameUp.sol";
// import "../interfaces/IHub.sol";

/**
 * @title GameExtension
 */
abstract contract GameExtension is Context {

    //--- Storage
    
    //--- Functions 

    //Use Self (Main Game)
    function game() internal view returns (IGame) {
        return IGame(address(this));
    }

    //Get Data Repo Address (From Hub)
    function repoAddr() public view returns (address) {
        return ICommonYJ(address(this)).repoAddr();
    }

    //Get Assoc Repo
    function repo() internal view returns (IOpenRepo) {
        return IOpenRepo(repoAddr());
    }

    /// Hub Address
    function hubAddress() internal view returns (address) {
        return ICommonYJ(address(this)).getHub();
    }
        
}
