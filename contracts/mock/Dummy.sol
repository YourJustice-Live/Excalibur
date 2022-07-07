// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


/**
 * @title Dummy Contract
 */
contract Dummy {

    constructor() {

    }


    function debugFunc() public pure returns(string memory){
        return "Hello World";
    }

    // function debugFunc2() public pure returns(string memory){
    //     return _implementation();
        // return uri(1);
    // }

}
