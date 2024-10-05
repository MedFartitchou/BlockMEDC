pragma solidity ^0.4.23;
pragma experimental ABIEncoderV2;  // Enables support for returning structs and dynamic arrays

import "./MC_Authority.sol";
import "./University.sol";
import "hardhat/console.sol";
import {SharedStructs} from "./Structs.sol";

contract Storage {

    address private owner;    // owner == Assistant Institution  
    uint private total;  // number of semesters 
    MC_Authority private Autho; // instance of Sc authority 
    University d;
    mapping(address => SharedStructs.TrStudent) private Trstudents;

    struct UserFile {
        string ipsHash;
    }

    // use to link an address with the stored files
    mapping(address => mapping(uint256 => UserFile)) public UserFiles;
    // use to check if an address already stores some files
    mapping(address => bool) public isSet;
    // use the address to track the number of stored files
    mapping(address => uint256) public lastID;

    constructor(address autho, address univ, address AInstitution, address head) public {
        d = University(univ);
        Autho = MC_Authority(autho);
        require(univ != address(0x0) && AInstitution != address(0x0) && d.CheckInstitution(AInstitution) == true);
        owner = head;
    }

    modifier onlyOwner {       
        require(msg.sender == owner);
        _;
    }

    function setUser(address _add) internal onlyOwner {
        isSet[_add] = true;
        lastID[_add] = 0; // Initialize with 0
    }

    function updateUser(address _add, uint256 _key) internal onlyOwner {
        lastID[_add] = _key;
    }

    function getLastUserID(address _add) internal view returns (uint256) {
        return lastID[_add];
    }

    function getLast(address _add) external view returns (uint256) {
        require(isSet[_add], "NO Files for this address");
        return (getLastUserID(_add) - 1);
    }

    function getAll() external view returns (UserFile[] memory) {
        require(isSet[msg.sender], "NO Files for this address");
        uint256 size = getLastUserID(msg.sender);
        UserFile[] memory allFiles = new UserFile[](size);
        for (uint256 i = 0; i < size; i++) {
            allFiles[i] = UserFiles[msg.sender][i];
        }
        return allFiles;
    }

   
    function store(string _ipsHash) external onlyOwner {
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
}
