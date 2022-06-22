//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../interfaces/IStringStore.sol";
import "../../libraries/StringArray.sol";

/**
 * @title String Storage Service
 * @dev Open Data Repository -- Retains String Values for Other Contracts
 * Version 3.0
 * - Save & Return Associations
 * - Owned by Requesting Address
 */
abstract contract StringStore is 
    IStringStore, 
    Context, 
    ERC165 {

    //--- Storage
    
    //Associations by Contract Address
    using StringArray for string[];
    mapping(address => mapping(string => string[])) internal _RepoString;
    
    //--- Events

    /// Association Set
    event StringSet(address originAddress, string key, string value);

    /// Association Added
    event StringAdd(address originAddress, string key, string value);

    /// Association Added
    event StringRemoved(address originAddress, string key, string value);

    //--- Functions

    /// ERC165 - Supported Interfaces
    // function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    //     return interfaceId == type(IStringStore).interfaceId 
    //         || super.supportsInterface(interfaceId);
    // }
    
    /// Get Boolean By Origin Owner Node
    function stringGetOf(address originContract, string memory key) public view override returns(string memory) {
        //Return Item
        return _RepoString[originContract][key][0];
    }

    /// Get First Boolean in Slot
    function stringGet(string memory key) external view override returns(string memory) {
        address originContract = _msgSender();
        //Validate
        return stringGetOf(originContract, key);
    }
    
    /// Get First Boolean by Index
    function stringGetIndexOf(address originContract, string memory key, uint256 index) public view override returns(string memory) {
        //Fetch
        return _RepoString[originContract][key][index];
    }

    /// Get First Boolean in Index
    function stringGetIndex(string memory key, uint256 index) external view override returns(string memory) {
        address originContract = _msgSender();
        //Fetch
        return stringGetIndexOf(originContract, key, index);
    }
    
    /// Get All Boolean in Slot
    function stringGetAll(string memory key) external view returns(string[] memory) {
        address originContract = _msgSender();
        //Validate
        return _RepoString[originContract][key];
    }

    /// Set Boolean
    function stringSet(string memory key, string memory value) external override {
        //Clear Entire Array
        delete _RepoString[_msgSender()][key];
        //Set as the first slot of an empty array
        _RepoString[_msgSender()][key].push(value);
        //Association Changed Event
        emit StringSet(_msgSender(), key, value);
    }
    
    /// Add Boolean to Slot
    function stringAdd(string memory key, string memory value) external override {
        //Add to Array
        _RepoString[_msgSender()][key].push(value);
        //Association Changed Event
        emit StringAdd(_msgSender(), key, value);
    }
    
    /// Remove Boolean from Slot
    function stringRemove(string memory key, string memory value) external override {
        //Set as the first slot of an empty array
        _RepoString[_msgSender()][key].removeItem(value);
        //Association Changed Event
        emit StringRemoved(_msgSender(), key, value);
    }
}