// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract Management {
    address private walletAddress = msg.sender;

    enum Party {
        Victim,
        Witness,
        Suspect
    }
    enum Roles {
        Investigator,
        ForensicAnalyst,
        Judge,
        Jury,
        Admin
    }

    struct CaseFile {
        string caseNo;
        string investigatorName;
        uint256 timeStamp;
        string evidenceList;
        string[] entityList;
        string[] sharedKeys;
        address createdBy;
    }

    struct Entity {
        string entityId;
        address createdBy;
        string data;
    }

    struct sharedKey {
        string id;
        Roles role;
        string key;
    }

    struct UserAccess {
        bool hasAccess;
    }

    struct RBAC {
        bool investigatorName;
        bool fileHash;
        bool name;
        bool email;
        bool gender;
        bool dob;
        bool phone;
        bool userAddress;
        bool additionalInfo;
    }

    struct CaseAccess {
        string[] caseList;
    }

    struct Activity {
        address userAddress;
        string eventLog;
        string variableID;
        uint256 timestamp;
    }

    mapping(string => CaseFile) private caseFiles;
    mapping(string => Entity) private entities;
    mapping(address => string[]) private userCaseFiles;
    mapping(Roles => RBAC) private rbacList;
    mapping(Roles => bool) private revokeList;
    mapping(Roles => CaseAccess) private caseAccessList;
    mapping(string => UserAccess) private userAccessList;
    mapping(string => sharedKey) private caseSharedKeys;
    mapping(address => Activity[]) private userEvents;

    // Array to store all case file & entity keys
    string[] private allCaseFiles;
    string[] private allEntities;

    event UserActivity(
        address indexed user,
        string eventLog,
        string variableID,
        uint256 timestamp
    );

    modifier caseExists(string memory _caseNo) {
        require(bytes(_caseNo).length > 0, "Case number must not be empty");
        require(caseFiles[_caseNo].timeStamp == 0, "Case file already exists");
        _;
    }

    modifier entityExists(string memory _entityID) {
        require(bytes(_entityID).length > 0, "Entity ID must not be empty");
        require(
            entities[_entityID].createdBy == address(0),
            "Entity already exists"
        );
        _;
    }

    constructor() {
        updateAccess(
            Roles.Admin,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true
        );
        updateAccess(
            Roles.Investigator,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true
        );
    }

    function createCaseFile(
        string memory _caseNo,
        string memory _investigatorName
    ) public caseExists(_caseNo) {
        CaseFile storage caseFile = caseFiles[_caseNo];
        caseFile.caseNo = _caseNo;
        caseFile.investigatorName = _investigatorName;
        caseFile.timeStamp = block.timestamp;
        caseFile.createdBy = walletAddress;

        emitActivity(walletAddress, "Created Case File", _caseNo);
        allCaseFiles.push(_caseNo);
        userCaseFiles[msg.sender].push(_caseNo);
    }

    function addEvidenceFile(
        string memory _caseNo,
        string memory _fileList
    ) public {
        require(bytes(_caseNo).length > 0, "Case number must not be empty");
        CaseFile storage caseFile = caseFiles[_caseNo];
        caseFile.evidenceList = _fileList;

        emitActivity(walletAddress, "Updated Evidence Files", _caseNo);
    }

    function addEntity(
        string memory _caseNo,
        string memory _entityId,
        string memory _data
    ) public entityExists(_entityId) {
        require(bytes(_caseNo).length > 0, "Case number must not be empty");
        Entity storage newEntity = entities[_entityId];
        newEntity.entityId = _entityId;
        newEntity.createdBy = walletAddress;
        newEntity.data = _data;

        emitActivity(walletAddress, "Created Entity", _entityId);
        caseFiles[_caseNo].entityList.push(_entityId);
        allEntities.push(_entityId);
    }

    function updateEntity(string memory _entityId, string memory _data) public {
        Entity storage existingEntity = entities[_entityId];
        existingEntity.data = _data;
        emitActivity(walletAddress, "Updated Entity", _entityId);
    }

    function createSharedKey(
        string memory _caseNo,
        string memory _id,
        Roles _role,
        string memory _key
    ) public {
        require(bytes(_caseNo).length > 0, "Case number must not be empty");
        require(bytes(_id).length > 0, "Key ID must not be empty");
        require(_role != Roles.Admin, "Cannot assign shared key to Admin role"); // Optionally, prevent assigning shared keys to Admin role
        require(bytes(_key).length > 0, "Key must not be empty");

        // CaseFile storage caseFile = caseFiles[_caseNo];
        sharedKey storage key = caseSharedKeys[_id];
        key.id = _id;
        key.role = _role;
        key.key = _key;
    }

    function updateSharedKeysInCaseFile(
        string memory _caseNo,
        string[] memory _sharedKeys
    ) public {
        require(bytes(_caseNo).length > 0, "Case number must not be empty");

        CaseFile storage caseFile = caseFiles[_caseNo];
        require(caseFile.timeStamp != 0, "Case file does not exist");

        caseFile.sharedKeys = _sharedKeys;
    }

    function updateAccess(
        Roles _role,
        bool _investigatorName,
        bool _fileHash,
        bool _name,
        bool _email,
        bool _gender,
        bool _dob,
        bool _phone,
        bool _userAddress,
        bool _additionalInfo
    ) public {
        rbacList[_role] = RBAC(
            _investigatorName,
            _fileHash,
            _name,
            _email,
            _gender,
            _dob,
            _phone,
            _userAddress,
            _additionalInfo
        );
    }

    function updateRoleAccess(string memory _email, bool _hasAccess) external {
        userAccessList[_email].hasAccess = _hasAccess;
    }

    function emitActivity(
        address _address,
        string memory _eventLog,
        string memory _variableID
    ) internal {
        Activity memory activity = Activity(
            _address,
            _eventLog,
            _variableID,
            block.timestamp
        );
        userEvents[msg.sender].push(activity);
        emit UserActivity(_address, _eventLog, _variableID, block.timestamp);
    }

    // Access Control

    function updateAccessList(
        Roles _role,
        bool _investigatorName,
        bool _fileHash,
        bool _name,
        bool _email,
        bool _gender,
        bool _dob,
        bool _phone,
        bool _userAddress,
        bool _additionalInfo
    ) public {
        rbacList[_role] = RBAC(
            _investigatorName,
            _fileHash,
            _name,
            _email,
            _gender,
            _dob,
            _phone,
            _userAddress,
            _additionalInfo
        );
    }

    function updateCaseAccess(Roles _role, string[] memory _caseNo) public {
        caseAccessList[_role].caseList = _caseNo;
    }

    function addUserAccess(string memory _email, bool _hasAccess) public {
        userAccessList[_email] = UserAccess(_hasAccess);
    }

    function getRBACList(Roles _role) public view returns (RBAC memory) {
        return rbacList[_role];
    }

    function getCaseAccess(
        Roles _role
    ) public view returns (CaseAccess memory) {
        return caseAccessList[_role];
    }

    function getUserAccess(
        string memory _email
    ) public view returns (UserAccess memory) {
        return userAccessList[_email];
    }

    function getCaseFile(
        string memory _caseNo
    ) public view returns (CaseFile memory) {
        CaseFile storage caseFile = caseFiles[_caseNo];
        return caseFile;
    }

    function getEntity(
        string memory _entityID
    ) public view returns (Entity memory) {
        Entity storage entityInfo = entities[_entityID];
        // require(entityInfo.createdBy != address(0), "Entity does not exist");
        return entityInfo;
    }

    function getSharedKey(
        string memory _id
    ) public view returns (sharedKey memory) {
        return caseSharedKeys[_id];
    }

    function getAllCaseFiles() public view returns (string[] memory) {
        return allCaseFiles;
    }

    function getAllEntities() public view returns (string[] memory) {
        return allEntities;
    }

    function getUserCaseFiles() public view returns (string[] memory) {
        return userCaseFiles[msg.sender];
    }

    function getUserEvents() public view returns (Activity[] memory) {
        return userEvents[msg.sender];
    }
}
