//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../interfaces/IBoolStore.sol";
import "../../libraries/BoolArray.sol";

/**
 * @title Boolean Storage Service
 * @dev Open Data Repository -- Retains Boolean Data for Other Contracts
 * Version 3.0
 * - Save & Return Associations
 * - Owned by Requesting Address
 */
abstract contract BoolStore is 
    IBoolStore, 
    Context, 
    ERC165 {

    //--- Storage
    
    //Associations by Contract Address
    using BoolArray for bool[];
    mapping(address => mapping(string => bool[])) internal _RepoBool;
    
    //--- Events

    /// Association Set
    event BoolSet(address originContract, string key, bool value);

    /// Association Added
    event BoolAdd(address originContract, string key, bool value);

    /// Association Added
    event BoolRemoved(address originContract, string key, bool value);


    //--- Functions

    /// ERC165 - Supported Interfaces
    // function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    //     return interfaceId == type(IBoolStore).interfaceId 
    //         || super.supportsInterface(interfaceId);
    // }

    /// Get Boolean By Origin Owner Node
    function boolGetOf(address originContract, string memory key) public view override returns(bool) {
        //Return Item
        return _RepoBool[originContract][key][0];
    }

    /// Get First Boolean in Slot
    function boolGet(string memory key) external view override returns(bool) {
        address originContract = _msgSender();
        //Validate
        return boolGetOf(originContract, key);
    }
    
    /// Get First Boolean by Index
    function boolGetIndexOf(address originContract, string memory key, uint256 index) public view override returns(bool) {
        //Fetch
        return _RepoBool[originContract][key][index];
    }

    /// Get First Boolean in Index
    function boolGetIndex(string memory key, uint256 index) external view override returns(bool) {
        address originContract = _msgSender();
        //Fetch
        return boolGetIndexOf(originContract, key, index);
    }
    
    /// Get All Boolean in Slot
    function boolGetAll(string memory key) external view returns(bool[] memory) {
        address originContract = _msgSender();
        //Validate
        return _RepoBool[originContract][key];
    }

    /// Set Boolean
    function boolSet(string memory key, bool value) external override {
        //Set as the first slot of a new empty array
        _RepoBool[_msgSender()][key] = [value];
        //Association Changed Event
        emit BoolSet(_msgSender(), key, value);
    }
    
    /// Add Boolean to Slot
    function boolAdd(string memory key, bool value) external override {
        _RepoBool[_msgSender()][key].push(value);
        //Association Changed Event
        emit BoolAdd(_msgSender(), key, value);
    }
    
    /// Remove Boolean from Slot
    function boolRemove(string memory key, bool value) external override {
        _RepoBool[_msgSender()][key].removeItem(value);
        //Association Changed Event
        emit BoolRemoved(_msgSender(), key, value);
    }
}