//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./interfaces/IActionRepo.sol";
// import "./libraries/DataTypes.sol";
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
    // mapping(uint256 => DataTypes.RoleData) internal _RoleData;      //Additional Data
    mapping(uint256 => string) internal _uri;



    //--- Functions

    // constructor(address hub) CommonYJ(hub) ERC1155GUID(""){
    constructor(address hub) CommonYJ(hub) ERC1155(""){
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
    function actionAdd(DataTypes.SVO memory svo, string memory uri) public override returns (bytes32) {
        //TODO: Validate

        // console.log("actionAdd");

        //Store Additional Details
        // return _actionAdd(svo);
        bytes32 guid = _actionAdd(svo);
        //Set Additional Data
        // _actionSetConfirmation(guid, confirmation);  //MOVED Confirmation to Rules
        _actionSetURI(guid, uri);
        //return GUID
        return guid;
    }

    /// Register New Actions in a Batch
    function actionAddBatch(DataTypes.SVO[] memory svos, string[] memory uris) external override returns (bytes32[] memory) {
        require(svos.length == uris.length, "Length Mismatch");
        bytes32[] memory guids;
        for (uint256 i = 0; i < svos.length; ++i) {
            guids[i] = actionAdd(svos[i], uris[i]);
        }
        return guids;
    }

    /// Update URI for Action
    function actionSetURI(bytes32 guid, string memory uri) external override {
        _actionSetURI(guid, uri);
    }

    /// Set Action's Metadata URI
    function _actionSetURI(bytes32 guid, string memory uri) internal {
        // _uri[_GUIDToId(guid)] = uri;
        // _RoleData[_GUIDToId(guid)].uri = uri;
        _uri[_GUIDToId(guid)] = uri;
        emit ActionURI(guid, uri);
    }

    /* Moved Confirmation to Rules
    
    /// Update Confirmation Method for Action
    function actionSetConfirmation(bytes32 guid, DataTypes.Confirmation memory confirmation) external override {
            _actionSetConfirmation(guid, confirmation);
    }

    /// Set Action's Confirmation Object
    function _actionSetConfirmation(bytes32 guid, DataTypes.Confirmation memory confirmation) internal {
        _RoleData[_GUIDToId(guid)].confirmation = confirmation;
        emit Confirmation(guid, confirmation.ruling, confirmation.evidence, confirmation.witness);
    }

    /// Get Action's URI
    function actionGetConfirmation(bytes32 guid) public view override returns (DataTypes.Confirmation memory){
        return _RoleData[_GUIDToId(guid)].confirmation;
    }

    */
    
    /// Store New Action
    function _actionAdd(DataTypes.SVO memory svo) internal returns (bytes32) {
        //Unique Token GUID
        bytes32 guid = actionHash(svo);
        //Validate 
        require(_GUIDExists(guid) == false, "Action Already Exists");
        //Create Action
        uint256 id = _GUIDMake(guid);
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
        // return _RoleData[_GUIDToId(guid)].uri;
        return _uri[_GUIDToId(guid)];
    }


    /* [TBD] - would need to track role IDs
    
    /// Create a new Role
    function roleCreate(string calldata role) public {
        
        _roleCreate(role);
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