pragma solidity ^0.4.23;
import {SharedStructs} from "./Structs.sol";
contract Certs_Profs{
 
    address private head ;
    address private A_insti ;
    address private owner;
    bool public valid; // State variable to track the validity of the diploma

   SharedStructs.Prdiploma private diplomas;
    modifier onlyGiver  {
        require(msg.sender == head);
        _;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
 
    constructor (address st,address Ainst,address inst) public  {
        require(st !=address(0x0) && Ainst !=address(0x0) && inst !=address(0x0)); 
        
        diplomas.receiver = st;
        diplomas.issuer_Institution = Ainst;
        diplomas.issuer_head = inst;
        owner = st;
        A_insti  = Ainst;
        head = inst;
        valid = true; // Set the diploma as valid when issued
    }

    event PrCertIssued(address from,address from1, address to, uint date);
    function emitt() public {
        diplomas.date = block.timestamp;
        diplomas.status = true;
        emit PrCertIssued(diplomas.issuer_Institution , diplomas.issuer_head, diplomas.receiver, diplomas.date);
    }

    event Revoked(address from, uint date);
    function revoke() public onlyGiver  {
        valid = false; // Mark the diploma as invalid when revoked
        selfdestruct(head);
        emit Revoked(head , block.timestamp);
    }
        // New isValid function to check if the diploma is still valid
    function isValid() public view returns (bool) {
        return valid; // Return the validity state of the diploma
    }
}