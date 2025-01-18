pragma solidity ^0.8.0;
import {SharedStructs} from "./Structs.sol";

contract Storage {
    address private owner; // owner == Institution
    mapping(address => SharedStructs.TrStudent) private Trstudents;

    struct UserFile {
        string ipsHash;
    }

    // Use to link an address with stored files
    mapping(address => mapping(uint256 => UserFile)) public UserFiles;
    // Use to check if an address already stores some files
    mapping(address => bool) public isSet;
    // Use the address to track the number of stored files
    mapping(address => uint256) public lastID;

    // Constructor (owner == Dean of Institution)
    constructor(address head) {
        require(head != address(0), "Invalid owner address");
        owner = head;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Access restricted to the owner");
        _;
    }

    // Internal function to initialize a user
    function setUser(address _add) internal onlyOwner {
        isSet[_add] = true;
        lastID[_add] = 0; // Initialize with 0
    }

    // Internal function to update the user's file count
    function updateUser(address _add, uint256 _key) internal onlyOwner {
        lastID[_add] = _key;
    }

    // Function to store a file
    function store(string calldata _ipsHash) external onlyOwner {
        if (isSet[msg.sender]) {
            uint256 key = getLastUserID(msg.sender);
            UserFiles[msg.sender][key] = UserFile(_ipsHash);
            updateUser(msg.sender, key + 1);
        } else {
            setUser(msg.sender);
            UserFiles[msg.sender][0] = UserFile(_ipsHash);
            updateUser(msg.sender, 1);
        }
    }

    // **Read Functions**

    // 📌 Get the Last File of a User
    function getLastFile(address _add) external view returns (string memory) {
        require(isSet[_add], "No files exist for this address");
        uint256 lastIndex = getLastUserID(_add);
        require(lastIndex > 0, "No files available");
        return UserFiles[_add][lastIndex - 1].ipsHash; // Last file
    }

    // 📌 Get a Specific File by Index
    function getFile(address _add, uint256 index) external view returns (string memory) {
        require(isSet[_add], "No files exist for this address");
        require(index < getLastUserID(_add), "Invalid file index");
        return UserFiles[_add][index].ipsHash; // File at the given index
    }

    // 📌 Get All Files of a User
    function getAllFiles(address _add) external view returns (UserFile[] memory) {
        require(isSet[_add], "No files exist for this address");
        uint256 size = getLastUserID(_add);
        UserFile[] memory allFiles = new UserFile[](size);
        for (uint256 i = 0; i < size; i++) {
            allFiles[i] = UserFiles[_add][i];
        }
        return allFiles;
    }

    // **Helper Functions**

    // Internal function to get the last file index
    function getLastUserID(address _add) internal view returns (uint256) {
        return lastID[_add];
    }
}

// FileHash1 : QmYwAPJzv5CZsnAzt8auVZRnZz3LrU3PwpZkeY3XJnQs4F
