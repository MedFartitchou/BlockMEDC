pragma solidity ^0.8.0;

import {SharedStructs} from "./Structs.sol";

contract TranscriptCert {

    address private giver;
    address private owner;
    SharedStructs.TranscriptCer private diplomas;

    bool public isRevoked; // Added a flag to track revocation status

    modifier onlyGiver {
        require(msg.sender == giver, "Only the giver can perform this action.");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    // Constructor now accepts two addresses and ensures they are valid
    constructor(address st, address inst) payable {
        require(st != address(0x0) && inst != address(0x0), "Invalid address provided.");

        diplomas.receiver = st;
        diplomas.issuer = inst;
        owner = st;
        giver = inst;
        isRevoked = false; // Set the initial revocation status to false
    }

    event TranscriptIssued(address from, address to, uint date);
    
    // Emitting the TranscriptIssued event with the correct details
    function emitt() public {
        require(!isRevoked, "This certificate has been revoked.");
        diplomas.date = block.timestamp;
        diplomas.status = true;

        emit TranscriptIssued(diplomas.issuer, diplomas.receiver, diplomas.date);
    }

    event Revoked(address from, uint date);
    
    // Revoke function that can only be executed by the giver (issuer)
    function revoke() public onlyGiver {
        isRevoked = true; // Mark the contract as revoked
        emit Revoked(giver, block.timestamp);
    }
}
