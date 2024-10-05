pragma solidity ^0.4.23;
import {SharedStructs} from "./Structs.sol";

contract Certs_Students {

    address private giver_dean;
    address private giver_president;
    address private owner;
    SharedStructs.Acdiploma private diplomas;
    bool public valid; // State variable to track the validity of the diploma

    modifier onlyGiver {
        require(msg.sender == giver_dean);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor(address st, address univ, address inst) public {
        require(st != address(0x0) && univ != address(0x0) && inst != address(0x0));

        diplomas.receiver = st;
        diplomas.issuer_president = univ;
        diplomas.issuer_dean = inst;
        owner = st;
        giver_president = univ;
        giver_dean = inst;
        valid = true; // Set the diploma as valid when issued
    }

    event AcaCertIssued(address from, address from1, address to, uint date);

    function emitt() public {
        diplomas.date = block.timestamp;
        diplomas.status = true;
        emit AcaCertIssued(diplomas.issuer_president, diplomas.issuer_dean, diplomas.receiver, diplomas.date);
    }

    event Revoked(address from, uint date);

    function revoke() public onlyGiver {
        valid = false; // Mark the diploma as invalid when revoked
        emit Revoked(giver_dean, block.timestamp);
    }

    // New isValid function to check if the diploma is still valid
    function isValid() public view returns (bool) {
        return valid; // Return the validity state of the diploma
    }
}
