// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "../libraries/DataTypes.sol";

interface IIncident {
    
    //-- Functions

    /// Initialize
    function initialize(address hub, string memory name_, string calldata uri_, DataTypes.RuleRef[] memory addRules, DataTypes.InputRoleToken[] memory assignRoles, address container) external ;

    /// Set Contract URI
    function setContractURI(string calldata contract_uri) external;

    /// Request to Join
    function nominate(uint256 soulToken, string memory uri) external;

    /// Assign Someone to a Role
    function roleAssign(address account, string calldata role) external;

    /// Assign Tethered Token to a Role
    function roleAssignToToken(uint256 ownerToken, string memory role) external;
        
    /// Remove Tethered Token from a Role
    function roleRemoveFromToken(uint256 ownerToken, string memory role) external;

    /// File the Incident (Validate & Open Discussion)  --> Open
    function stageFile() external;

    /// Incident Wait For Verdict  --> Pending
    function stageWaitForVerdict() external;

    /// Incident Stage: Place Verdict  --> Closed
    // function stageVerdict(string calldata uri) external;
    function stageVerdict(DataTypes.InputDecision[] calldata verdict, string calldata uri) external;

    /// Incident Stage: Reject Incident --> Cancelled
    function stageCancel(string calldata uri) external;

    /// Add Post 
    function post(string calldata entRole, uint256 tokenId, string calldata uri) external;

    /// Set Metadata URI For Role
    function setRoleURI(string memory role, string memory _tokenURI) external;

    //Get Contract Association
    // function getAssoc(string memory key) external view returns(address);

    //--- Events

    /// Incident Stage Change
    event Stage(DataTypes.IncidentStage stage);

    /// Post Verdict
    event Verdict(string uri, address account);

    /// Incident Cancelation Data
    event Cancelled(string uri, address account);

    /// Rule Reference Added
    event RuleAdded(address game, uint256 ruleId);

    //Rule Confirmed
    event RuleConfirmed(uint256 ruleId);

    //Rule Denied (Changed from Confirmed)
    // event RuleDenied(uint256 ruleId);
    
    /// Nominate
    event Nominate(address account, uint256 indexed id, string uri);

}
