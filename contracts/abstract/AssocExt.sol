//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

// import "../interfaces/IAssocRepo.sol";
import "../public/interfaces/IOpenRepo.sol";

/**
 * @title Generic Associations (to other contracts)
 * @dev To Extend or Be Used by other contracts
 * - Hold, Update & Serve Associations
 */
abstract contract AssocExt {
    //--- Storage
    IOpenRepo private _OpenRepo;
    
    //--- Functions

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
