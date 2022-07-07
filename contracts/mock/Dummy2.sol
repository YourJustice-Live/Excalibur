// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


/**
 * @title Dummy Contract #2
 */
contract Dummy2 {

    constructor() {

    }


    function debugFunc() public pure returns(string memory){
        return "Hello World 2";
    }

    function debugFunc2() public pure returns(string memory){
        return "Hello World 2.2";
    }

}
