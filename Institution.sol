pragma solidity ^0.8.0;

import {SharedStructs} from "./Structs.sol";

contract MC_Authority {
    address private owner;
    address[] private revoked;

    mapping(address => SharedStructs.PKI_Certificate) private certs;

    // Modifier for restricted access
    modifier onlyOwner() {
        require(msg.sender == owner, "Access restricted to the owner");
        _;
    }

    // Constructor (Updated for Solidity ^0.8.0)
    constructor() payable {
        owner = msg.sender;
    }

    // Event for Certificate Registration
    event Certified(address indexed from, address indexed to, uint256 date);

    // Register a Trusted Entity
    function RegisterCert(address university, bytes32 publicKey, uint256 expiry) public onlyOwner {
        require(university != address(0), "Invalid university address");

        certs[university].identity = university;
        certs[university].publicKey = publicKey;
        certs[university].expiry = expiry;
        certs[university].revoked = false;
        certs[university].registered = true;

        emit Certified(owner, university, block.timestamp);
    }

    // Event for Certificate Revocation
    event Revoked(address indexed from, address indexed to, uint256 date);

    // Revoke a Certificate
    function revoke(address university) public onlyOwner {
        require(university != address(0), "Invalid university address");
        require(certs[university].registered, "Certificate not registered");

        certs[university].revoked = true;
        revoked.push(university);

        emit Revoked(owner, university, block.timestamp);
    }

    // Check if a Certificate is Valid
    function isCertificateValid(address university) public view returns (bool) {
        require(university != address(0), "Invalid university address");
        require(certs[university].registered, "Certificate not registered");

        if (certs[university].revoked || certs[university].expiry < block.timestamp) {
            return false;
        }
        return true;
    }

    // Retrieve Revoked Certificates List
    function cert_revo_list() external view returns (address[] memory) {
        return revoked;
    }
}
