// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "../libraries/DataTypes.sol";

interface ICase {
    
    //-- Functions

    /// Initialize
    function initialize(address hub, string memory name_, string calldata uri_, DataTypes.RuleRef[] memory addRules, DataTypes.InputRoleToken[] memory assignRoles, address container) external ;

    /// Set Contract URI
    function setContractURI(string calldata contract_uri) external;

    /// Assign Someone to a Role
    function roleAssign(address account, string calldata role) external;

    /// Assign Tethered Token to a Role
    function roleAssignToToken(uint256 ownerToken, string memory role) external;
        
    /// Remove Tethered Token from a Role
    function roleRemoveFromToken(uint256 ownerToken, string memory role) external;

    // RoleRequest()

    // RoleOffered()

    // RoleAccepted()

    // RoleAssigned()

    /// File the Case (Validate & Open Discussion)  --> Open
    function stageFile() external;

    /// Case Wait For Verdict  --> Pending
    function stageWaitForVerdict() external;

    /// Case Stage: Place Verdict  --> Closed
    // function stageVerdict(string calldata uri) external;
    function stageVerdict(DataTypes.InputDecision[] calldata verdict, string calldata uri) external;

    /// Case Stage: Reject Case --> Cancelled
    function stageCancel(string calldata uri) external;

    /// Add Post 
    function post(string calldata entRole, uint256 tokenId, string calldata uri) external;

    /// Set Metadata URI For Role
    function setRoleURI(string memory role, string memory _tokenURI) external;

    //--- Events

    /// Case Stage Change
    event Stage(DataTypes.CaseStage stage);

    /// Post Verdict
    event Verdict(string uri, address account);

    /// Case Cancelation Data
    event Cancelled(string uri, address account);

    /// Rule Reference Added
    event RuleAdded(address jurisdiction, uint256 ruleId);

    //Rule Confirmed
    event RuleConfirmed(uint256 ruleId);

    //Rule Denied (Changed from Confirmed)
    // event RuleDenied(uint256 ruleId);
    
}
