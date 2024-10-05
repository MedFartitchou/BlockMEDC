pragma solidity ^0.4.23;
import {SharedStructs} from "./Structs.sol";
//pragma solidity >=0.7.0 <0.9.0;

contract MC_Authority{
 
    address private owner;
    address[] private revoked;

    mapping (address => SharedStructs.PKI_Certificate) private certs;
 
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
      constructor() public payable {
        owner = msg.sender;
    }  
    event Certified(address from, address to, uint date);
   // Add a trusted entity. Owner of the PKI only
    function RegisterCert(address university, bytes32 publicKey, uint expiry) public onlyOwner {
        require(university != address(0x0));
 
        certs[university].identity = university;
        certs[university].publicKey = publicKey;
        certs[university].expiry = expiry;
        certs[university].revoked = false;
        certs[university].registered = true;
 
        emit Certified(owner, university, block.timestamp);
    }

        event Revoked(address from, address to, uint date);
 
    function revoke(address university) public onlyOwner {
        require(university != address(0x0) && certs[university].registered);
 
        certs[university].revoked = true;
        revoked.push(university);
 
        emit Revoked(owner, university, block.timestamp);
    }
 
    function isCertificateValid(address university) public view returns(bool) {
        require(university != address(0x0) && certs[university].registered);
 
        if (certs[university].revoked || certs[university].expiry < block.timestamp) // 
            return false;
        return true;
    }
 
    function cert_revo_list() external view returns(address[] memory) {
        return revoked;
    }

    }
