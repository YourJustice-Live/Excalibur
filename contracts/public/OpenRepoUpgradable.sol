//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./interfaces/IOpenRepo.sol";
import "../abstract/ContractBase.sol";
import "../libraries/AddressArray.sol";
import "../libraries/BoolArray.sol";
import "../libraries/StringArray.sol";


/**
 * @title Generic Data Repository
 * @dev Retains Data for Other Contracts
 * Version 2.1.0
 * - Save & Return Associations
 * - Owned by Requesting Address/Booleans/Strings
 * - Support Multiple Similar Items
 *
 * Address Functions:
    Set 
    Add
    Remove 
    Get (first) 
    GetAll
    GetSlot(index)
 */
contract OpenRepoUpgradable is 
        IOpenRepo, 
        Initializable,
        // Context, 
        OwnableUpgradeable,
        UUPSUpgradeable,
        ERC165,
        // BoolStore,
        // StringStore,
        ContractBase {

    //--- Storage
    
    //Arbitrary Contract Name & Symbol 
    string public constant symbol = "OPENREPO";
    string public constant name = "Open Edge Repository";
    
    using AddressArray for address[];
    mapping(address => mapping(string => address[])) internal _addressesMulti;
    
    //Associations by Contract Address
    using StringArray for string[];
    mapping(address => mapping(string => string[])) internal _RepoString;
   
    //Associations by Contract Address
    using BoolArray for bool[];
    mapping(address => mapping(string => bool[])) internal _RepoBool;
    
    //--- Functions

    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IOpenRepo).interfaceId 
            || super.supportsInterface(interfaceId);
    }

    /// Initializer
    function initialize () public initializer {
        //Initializers
        __Ownable_init();
        //Set Contract URI
        // _setContractURI(uri_);
    }

    /// Upgrade Permissions
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override { }


    //-- Addresses 

    /// Get Address By Origin Owner Node
    function addressGetOf(address originContract, string memory key) public view override returns(address) {
        //Validate
        require(_addressesMulti[originContract][key][0] != address(0) , string(abi.encodePacked("Faild to Find Address: ", key)));
        return _addressesMulti[originContract][key][0];
    }

    /// Get First Address in Slot
    function addressGet(string memory key) external view override returns(address) {
        address originContract = _msgSender();
        //Validate
        return addressGetOf(originContract, key);
    }
    
    /// Get First Address by Index
    function addressGetIndexOf(address originContract, string memory key, uint256 index) public view override returns(address) {
        //Fetch
        return _addressesMulti[originContract][key][index];
    }

    /// Get First Address in Index
    function addressGetIndex(string memory key, uint256 index) external view override returns(address) {
        address originContract = _msgSender();
        //Fetch
        return addressGetIndexOf(originContract, key, index);
    }
    
    /// Get All Address in Slot
    function addressGetAll(string memory key) external view returns(address[] memory) {
        address originContract = _msgSender();
        //Validate
        return _addressesMulti[originContract][key];
    }

    /// Set Address
    function addressSet(string memory key, address value) external override {
        //Set as the first slot of a new empty array
        _addressesMulti[_msgSender()][key] = [value];
        //Association Changed Event
        emit AddressSet(_msgSender(), key, value);
    }
    
    /// Add Address to Slot
    function addressAdd(string memory key, address value) external override {
        _addressesMulti[_msgSender()][key].push(value);
        //Association Changed Event
        emit AddressAdd(_msgSender(), key, value);
    }
    
    /// Remove Address from Slot
    function addressRemove(string memory key, address value) external override {
        _addressesMulti[_msgSender()][key].removeItem(value);
        //Association Changed Event
        emit AddressRemoved(_msgSender(), key, value);
    }

    //-- Booleans


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

    //-- Strings

        
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