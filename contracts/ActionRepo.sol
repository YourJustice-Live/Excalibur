//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// import {DataTypes} from './libraries/DataTypes.sol';
import "./interfaces/IActionRepo.sol";
import "./libraries/DataTypes.sol";
// import "./abstract/Rules.sol";
import "./abstract/CommonYJ.sol";
import "./abstract/ERC1155GUID.sol";


/**
 * @title History Retention
 * @dev Event Repository -- Reains Unique Events and Their Apperance Throught History
 * 2D - Compound GUID + Additional Data & URI
 * [TBD] 3D - Individual Instances of Action (Incidents) as NFTs + Event Details (Time, Case no.,  etc')
 */
contract ActionRepo is IActionRepo, CommonYJ, ERC1155GUID {

    //--- Storage
    //Arbitrary Contract Role 
    string public constant override symbol = "YJ_HISTORY";

    // Contract name
    string public name;
    // Contract symbol
    // string public symbol;
    //Jurisdiction
    address private _jurisdiction;
    //Rule(s)

    // Event Storage     (Unique Concepts)
    // mapping(bytes32 => Action) internal _actions;
    // mapping(uint256 => DataTypes.Action) internal _actions;
    mapping(bytes32 => DataTypes.SVO) internal _actions;            //Primary Data
    // mapping(bytes32 => DataTypes.SVO) public actionsTest;
    mapping(uint256 => DataTypes.RoleData) internal _RoleData;      //Additional Data

    // mapping(uint256 => string) internal _uri;



    //--- Functions

    constructor(address hub) CommonYJ(hub) ERC1155GUID(""){
        name = "YourJustice Event Repo";
    }

    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IActionRepo).interfaceId || super.supportsInterface(interfaceId);
    }

    /// Generate a Unique Hash for Event
    function actionHash(DataTypes.SVO memory svo) public pure override returns (bytes32) {
        // return bytes32(keccak256(abi.encode(svo.subject, svo.verb, svo.object, svo.tool, svo.affected)));
        return bytes32(keccak256(abi.encode(svo.subject, svo.verb, svo.object, svo.tool)));
    }

    /// Register New Action
    // function actionAdd(DataTypes.SVO memory svo) external returns (bytes32) {
    function actionAdd(DataTypes.SVO memory svo, DataTypes.Confirmation memory confirmation, string memory uri) public override returns (bytes32) {
        //TODO: Validate

        // console.log("actionAdd");

        //Store Additional Details
        // return _actionAdd(svo);
        bytes32 guid = _actionAdd(svo);
        //Set Additional Data
        _actionSetConfirmation(guid, confirmation);
        _actionSetURI(guid, uri);
        //return GUID
        return guid;
    }

    /// Register New Actions in a Batch
    function actionAddBatch(DataTypes.SVO[] memory svos, DataTypes.Confirmation[] memory confirmations, string[] memory uris) public override returns (bytes32) {
        require(svos.length == confirmations.length && svos.length == uris.length, "Length Mismatch");
        for (uint256 i = 0; i < svos.length; ++i) {
            actionAdd(svos[i], confirmations[i], uris[i]);
        }
    }

    /// Update URI for Action
    function actionSetURI(bytes32 guid, string memory uri) external override {
        _actionSetURI(guid, uri);
    }

    /// Update Confirmation Methof for Action
    function actionSetConfirmation(bytes32 guid, DataTypes.Confirmation memory confirmation) external override {
        _actionSetConfirmation(guid, confirmation);
    }

    /// Set Action's Metadata URI
    function _actionSetURI(bytes32 guid, string memory uri) internal {
        // _uri[_GUIDToId(guid)] = uri;
        _RoleData[_GUIDToId(guid)].uri = uri;
        emit ActionURI(guid, uri);
    }

    /// Set Action's Confirmation Object
    function _actionSetConfirmation(bytes32 guid, DataTypes.Confirmation memory confirmation) internal {
        _RoleData[_GUIDToId(guid)].confirmation = confirmation;
        emit Confirmation(guid, confirmation.ruling, confirmation.evidence, confirmation.witness);
    }

    /// Store New Action
    function _actionAdd(DataTypes.SVO memory svo) internal returns (bytes32) {
        //Unique Token GUID
        bytes32 guid = actionHash(svo);
        //Validate 
        require(_GUIDExists(guid) == false, "Action Already Exists");
        //Create Action
        uint256 id = _GUIDMake(guid);

        // console.log("New Action id: ", id);
        // console.log("New Action SVO: ", svo.subject);

        //Map Additional Data
        _actions[guid] = svo;
        //Event
        // emit ActionAdded(id, guid, svo.subject, svo.verb, svo.object, svo.tool, svo.affected);
        emit ActionAdded(id, guid, svo.subject, svo.verb, svo.object, svo.tool);
        //Return GUID
        return guid;
    }

    /// Get Action by GUID
    function actionGet(bytes32 guid) public view override returns (DataTypes.SVO memory){
        return _actionGet(guid);
    }

    /// Get Action by GUID
    // function _actionGet(bytes32 guid) internal view GUIDExists(guid) returns (DataTypes.SVO memory){
    function _actionGet(bytes32 guid) internal view returns (DataTypes.SVO memory){
        // return _actions[_GUIDToId(guid)];
        return _actions[guid];
    }

    /// Get Action's URI
    function actionGetURI(bytes32 guid) public view override returns (string memory){
        return _RoleData[_GUIDToId(guid)].uri;
    }

    /// Get Action's URI
    function actionGetConfirmation(bytes32 guid) public view override returns (DataTypes.Confirmation memory){
        return _RoleData[_GUIDToId(guid)].confirmation;
    }


    /* [TBD] - would need to track role IDs
    
    /// Create a new Role
    function roleCreate(string calldata role) public {
        
        _roleCreate(role);
    }
    */

    //-- Helpers
    /*
    function bytes32ToString(bytes32 source) internal pure returns (string memory result) {
        uint8 length = 0;
        while (source[length] != 0 && length < 32) {
            length++;
        }
        assembly {
            result := mload(0x40)
            // new "memory end" including padding (the string isn't larger than 32 bytes)
            mstore(0x40, add(result, 0x40))
            // store length in memory
            mstore(result, length)
            // write actual data
            mstore(add(result, 0x20), source)
        }
    }
    /// 
    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
    */

    //-- Playground


    function testBytes(bytes memory foo) public view returns (bytes memory){
        console.log("Bytes:");
        console.logBytes(foo);
        return foo;
    }

    function name2() public view returns (string memory){
        return name;
    }



}