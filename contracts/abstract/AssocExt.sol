//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "../interfaces/IAssocRepo.sol";

/**
 * @title Generic Associations (to other contracts)
 * @dev To Extend or Be Used by other contracts
 * - Hold, Update & Serve Associations
 */
abstract contract AssocExt {
    //AssocExt
            
    //--- Storage
    IAssocRepo private _AssocRepo;

    //--- Functions

    //Set Assoc Repo
    function _setAssocRepo(IAssocRepo assocRepo_) internal {
        _AssocRepo = assocRepo_;
    }

    //Get Assoc Repo
    function assocRepo() internal view returns (IAssocRepo) {
        return _AssocRepo;
    }

}
