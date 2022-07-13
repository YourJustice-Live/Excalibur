// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// import "../ERC1155D.sol";
// import "../ERC1155Tracker.sol";
import "../HubUpgradable.sol";


/**
 * @title HubMock
 */
contract HubMock is HubUpgradable {

    constructor(
        address openRepo,
        address config, 
        address gameContract, 
        address reactionContract
        ) {
        initialize(
            openRepo,
            config, 
            gameContract, 
            reactionContract
        );
    }

}
