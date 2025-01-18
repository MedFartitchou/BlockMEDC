pragma solidity ^0.8.0;

import {SharedStructs} from "./Structs.sol";

contract Certs_Students {
    address private giver_dean;
    address private giver_president;
    address private owner;
    bool public valid; // State variable to track the validity of the diploma

    SharedStructs.Acdiploma private diplomas;

    modifier onlyGiver() {
        require(msg.sender == giver_dean, "Only the dean can perform this action");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor(address st, address univ, address inst) {
        require(st != address(0), "Invalid student address");
        require(univ != address(0), "Invalid university address");
        require(inst != address(0), "Invalid dean address");

        diplomas.receiver = st;
        diplomas.issuer_president = univ;
        diplomas.issuer_dean = inst;
        owner = st;
        giver_president = univ;
        giver_dean = inst;
        valid = true; // Set the diploma as valid when issued
    }

    event AcaCertIssued(address from, address from1, address to, uint256 date);

    function emitt() public onlyOwner {
        diplomas.date = block.timestamp;
        diplomas.status = true;
        emit AcaCertIssued(diplomas.issuer_president, diplomas.issuer_dean, diplomas.receiver, diplomas.date);
    }

    event Revoked(address from, uint256 date);

    function revoke() public onlyGiver {
        valid = false; // Mark the diploma as invalid when revoked
        emit Revoked(giver_dean, block.timestamp);
    }

    /// @notice Check if the diploma is still valid
    function isValid() public view returns (bool) {
        return valid;
    }

    /// @notice Fallback function to accept Ether if sent directly to the contract
    receive() external payable {}
}
