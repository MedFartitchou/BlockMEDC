pragma solidity ^0.4.23;
import {SharedStructs} from "./Structs.sol";

contract TranscriptCert{
 
    address private giver ;
    address private owner;
    SharedStructs.TranscriptCer private diplomas;
    modifier onlyGiver  {
        require(msg.sender == giver );
        _;
    }
 
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
 
    constructor(address st, address inst) public payable {
        require(st !=address(0x0)  && inst !=address(0x0)); 

        diplomas.receiver = st;
        diplomas.issuer = inst;
        owner = st;
        giver  = inst;
    }

 
    event TranscriptIssued(address from, address to, uint date);
    function emitt() public {
        diplomas.date = block.timestamp;
        diplomas.status = true;
 
        emit TranscriptIssued(diplomas.issuer, diplomas.receiver, diplomas.date);
    }

    event Revoked(address from, uint date);
    function revoke() public onlyGiver  {
        selfdestruct(giver);
        emit Revoked(giver , block.timestamp);
    }
 
}