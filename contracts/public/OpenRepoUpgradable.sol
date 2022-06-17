//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../interfaces/IOpenRepo.sol";
import "../abstract/ContractBase.sol";
import "../libraries/AddressArray.sol";

/**
 * @title Generic Data Repository
 * @dev Retains Data for Other Contracts
 * Version 2.0.0
 * - Save & Return Associations
 * - Owned by Requesting Address
 * - Support Multiple Similar Associations
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
        ContractBase {

    //--- Storage
    
    //Arbitrary Contract Name & Symbol 
    string public constant symbol = "OPENREPO";
    string public constant name = "Open Edge Repository";
    
    //Associations by Contract Address
    mapping(address => mapping(string => address)) internal _addresses; //DEPRECATED


    using AddressArray for address[];
    mapping(address => mapping(string => address[])) internal _addressesMulti;
    
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
        //Set as the first slot of an empty array
        _addressesMulti[_msgSender()][key] = [value];
        //Association Changed Event
        emit AddressSet(_msgSender(), key, value);
    }
    
    /// Add Address to Slot
    function addressAdd(string memory key, address value) external override {
        //Set as the first slot of an empty array
        _addressesMulti[_msgSender()][key].push(value);
        //Association Changed Event
        emit AddressAdd(_msgSender(), key, value);
    }
    
    /// Remove Address from Slot
    function addressRemove(string memory key, address value) external override {
        //Set as the first slot of an empty array
        _addressesMulti[_msgSender()][key].removeItem(value);
        //Association Changed Event
        emit AddressRemoved(_msgSender(), key, value);
    }
}