//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../interfaces/IProtocolEntity.sol";
import "../interfaces/IHub.sol";
import "../libraries/DataTypes.sol";
import "../abstract/ContractBase.sol";
import "../public/interfaces/IOpenRepo.sol";
import "../libraries/Utils.sol";

/**
 * Common Protocol Functions
 */
abstract contract ProtocolEntityUpgradable is 
        IProtocolEntity, 
        ContractBase, 
        OwnableUpgradeable {
    
    //--- Storage

    // address internal _HUB;    //Hub Contract
    IHub internal _HUB;    //Hub Contract
    

    //--- Functions

    /// Initializer
    function __ProtocolEntity_init(address hub) internal onlyInitializing {
        //Set Protocol's Config Address
        _setHub(hub);
    }

    /// Inherit owner from Protocol's config
    function owner() public view override(IProtocolEntity, OwnableUpgradeable) returns (address) {
        return _HUB.owner();
    }

    /// Get Current Hub Contract Address
    function getHub() external view override returns(address) {
        return _getHub();
    }

    /// Set Hub Contract
    function _getHub() internal view returns(address) {
        return address(_HUB);
    }
    
    /// Change Hub (Move To a New Hub)
    function setHub(address hubAddr) external override {
        require(_msgSender() == address(_HUB), "HUB:UNAUTHORIZED_CALLER");
        _setHub(hubAddr);
    }

    /// Set Hub Contract
    function _setHub(address hubAddr) internal {
        //Validate Contract's Designation
        require(Utils.stringMatch(IHub(hubAddr).role(), "Hub"), "Invalid Hub Contract");
        //Set
        _HUB = IHub(hubAddr);
    }

    //** Data Repository 
    
    //Get Data Repo Address (From Hub)
    function repoAddr() public view override returns (address) {
        return _HUB.repoAddr();
    }

    //Get Assoc Repo
    function repo() internal view returns (IOpenRepo) {
        return IOpenRepo(repoAddr());
    }
    
    /// Generic Config Get Function
    // function confGet(string memory key) public view override returns(string memory) {
    //     return repo().stringGet(key);
    // }

    /// Generic Config Set Function
    function _confSet(string memory key, string memory value) internal {
        repo().stringSet(key, value);
    }

}
