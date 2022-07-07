// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// import "../public/interfaces/IOpenRepo.sol";
// import "../interfaces/IGameUp.sol";
import "../abstract/GameExtension.sol";


/**
 * @title Dummy Contract #2
 */
contract Dummy2 is GameExtension {

    //--- Storage

    
    //--- Functions 

    // constructor() { }

    //** Debug Functions

    function debugFunc() public pure returns(string memory){
        return "Hello World 2";
    }

    function debugFunc2() public pure returns(string memory){
        return "Hello World 2.2";
    }

    /// Try to Use Self (Main Contract's Functions)
    function useSelf() public view returns(string memory){
        string memory gameType = _game().confGet("type");
        return string(abi.encodePacked("Game Type: ", gameType));
    }


}
