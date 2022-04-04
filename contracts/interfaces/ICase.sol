// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICase {
    function initialize (
        string memory name_, 
        string memory symbol_, 
        address hub 
    ) external ;
    
}
