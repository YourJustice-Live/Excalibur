//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";

// import "../interfaces/IAssocRepo.sol";
import "../public/interfaces/IOpenRepo.sol";

/**
 * @title Generic Associations (to other contracts)
 * @dev To Extend or Be Used by other contracts
 * - Hold, Update & Serve Associations
 */
abstract contract AssocExt {
    //AssocExt
            
    //--- Storage
    IOpenRepo private _OpenRepo;
    /*
    IAssocRepo private _AssocRepo;
    
    //--- Functions

    //--- Legacy Functions (DEPRECATE)

    //Set Assoc Repo
    function _setAssocRepo(IAssocRepo assocRepo_) internal {
        _AssocRepo = assocRepo_;
    }

    //Get Assoc Repo
    function assocRepo() internal view returns (IAssocRepo) {
        return _AssocRepo;
    }

    */

    //--- New Version

    //Set Assoc Repo
    function _setRepo(address reposotoryAddress_) internal {
        // console.log("Setting Repo", address(reposotoryAddress_));
        // _OpenRepo = reposotoryAddress_;
        _OpenRepo = IOpenRepo(reposotoryAddress_);
    }

    //Get Assoc Repo
    function repo() internal view returns (IOpenRepo) {
        return _OpenRepo;
    }
    

}
